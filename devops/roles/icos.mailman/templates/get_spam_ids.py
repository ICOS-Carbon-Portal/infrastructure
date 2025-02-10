# Generate list of spam IDs from Hyperkitty archives
# Intended to run on mailman host server

import time

# Check the ENTIRE archives, using ALL open and archived lists
# - mail received in the last 48 hours
# - check for spam using machine learning spam identification

# Requires config.ini file in same directory, structured as follows:
# [mm_settings]
# url    = https://lists.icos-ri.eu/rest/3.0/
# user   = username_with_full_rest_access_goes_here
# pass   = password_goes_here
# ------------------------------------------------------------
# [mm_credentials]
# login    = username_with_full_admin_goes_here
# password = password_goes_here

from transformers import BertTokenizer, BertForSequenceClassification
from transformers import (AutoTokenizer, AutoModelForSeq2SeqLM,
                          AutoModelForSequenceClassification)
import re
import html
import requests
import json
import configparser
import csv
from bs4 import BeautifulSoup
from mailmanclient import Client
from datetime import datetime, timedelta, timezone

total_execution_time_start = time.time()
# path for persistent file storage:
PATH_PREFIX = "/docker/mailman/"
LOG_FILENAME = f"{PATH_PREFIX}spam_detection.log"
TCACHE_FILENAME = f"{PATH_PREFIX}translation_cache.csv"
CONFIG_FILENAME = f"{PATH_PREFIX}config.ini"
SPAM_IDS_FILE = f"{PATH_PREFIX}all_spam_ids.csv"


# for logging
def write_log(str):
    timestr = time.strftime("%Y%m%d-%H%M%S")
    with open(LOG_FILENAME, 'a', encoding="utf-8") as logfile:
        logfile.write(f"[{timestr}] {str}\n")


write_log("Beginning to load ML models")
# Load translation (german to english only) model
language_tokenizer = AutoTokenizer.from_pretrained(
    "Helsinki-NLP/opus-mt-de-en")
language_model = AutoModelForSeq2SeqLM.from_pretrained(
    "Helsinki-NLP/opus-mt-de-en")

# Load spam identification model
bert_model = "ar4min/SpamHunter"
bert_tokenizer = BertTokenizer.from_pretrained(bert_model)
bert_model = BertForSequenceClassification.from_pretrained(bert_model)

# Load language identification model
language_id_tokenizer = AutoTokenizer.from_pretrained(
    "papluca/xlm-roberta-base-language-detection")
language_id_model = AutoModelForSequenceClassification.from_pretrained(
    "papluca/xlm-roberta-base-language-detection")
id2lang = language_id_model.config.id2label

write_log("ML models successfully loaded")

# Translation cache persists between mailing lists and should be
# maintained between runs
translation_cache = {}

# rebuild from previous translation cache
try:
    with open(TCACHE_FILENAME, newline='', encoding="utf-8") as csvfile:
        tcache_reader = csv.reader(csvfile, delimiter=',')
        for row in tcache_reader:
            translation_cache[row[0]] = row[1]
        write_log(f"Rebuilt translation cache: {len(translation_cache.keys())}"
                  + " entries")
except FileNotFoundError:
    translation_cache = {}


# Write cache files to disk, for resuming later
def write_cache_file(timestr=None):
    if timestr is None:
        timestr = time.strftime("%Y%m%d-%H%M%S")
    # Write translation cache
    filename = TCACHE_FILENAME
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerows(list(translation_cache.items()))


# Identify language by two-character code (i.e. de = German, en = English)
def identify_language(text):
    inputs = language_id_tokenizer(text,
                                   return_tensors="pt",
                                   max_length=512,
                                   truncation=True)
    outputs = language_id_model(**inputs).logits.argmax(-1).item()
    return id2lang[outputs]


# Translate German text to English text, one "sentence" at a time
def translate_g2e(text):
    # translate sentence by sentence
    translated_text = ""
    chunks = re.split("([.!?\n|]+)", text)
    max_x = (int)((len(chunks)-1)/2)
    # will cut off last part of text if it is not terminated with punctuation
    remaining = ""
    # add subject to translated text without having to "translate" it
    # this allows for better cache building
    translated_text += chunks[0] + chunks[1] + " "
    for x in range(1, max_x):
        sentence = remaining + chunks[x*2] + chunks[x*2+1]
        if len(sentence) < 50:
            remaining += sentence
            continue
        else:
            remaining = ""
        if sentence in translation_cache:
            t_sentence = translation_cache[sentence]
        else:
            language_inputs = language_tokenizer(sentence,
                                                 return_tensors="pt",
                                                 max_length=512,
                                                 truncation=True).input_ids
            language_outputs = language_model.generate(language_inputs)
            t_sentence = language_tokenizer.decode(language_outputs[0],
                                                   skip_special_tokens=True)
            translation_cache[sentence] = t_sentence
        translated_text += t_sentence + " "
    return translated_text


# Check, using our BERT model, if text is spam
def is_spam_bert(text):
    inputs = bert_tokenizer(text,
                            return_tensors="pt",
                            max_length=512,
                            truncation=True)
    outputs = bert_model(**inputs)
    prediction = outputs.logits.argmax(-1).item()
    return prediction == 1


# Defining functions for converting messages to easier to process strings
# and processing Email objects into text
style_pattern = r"<style.*</style"
script_pattern = r"<script.*</script>"
re_flags = re.MULTILINE | re.DOTALL


def strip_string(s):
    stripped = re.sub("<[^<]+?>", "", s, flags=re_flags)
    stripped = re.sub("nbsp;", " ", stripped, flags=re_flags)
    stripped = re.sub("[\n\r\t]", " ", stripped, flags=re_flags)
    stripped = re.sub("[ ]+", " ", stripped, flags=re_flags)
    # correct for repeated ampersands, as some spam messages have these
    stripped = re.sub("& [& ]+", "& ", stripped, flags=re_flags)
    return stripped


# Process an email (as a JSON object already) with requests
# using given session sess
def process_email(email, sess):
    txt = email["subject"] + " | " + strip_string(email["content"])

    attachments = email["attachments"]
    for a in attachments:
        if a["content_type"] == "text/html":
            html_a = sess.get(a["download"])
            htmltext = html_a.text
            stripped = re.sub(style_pattern, '', htmltext, flags=re_flags)
            stripped = re.sub(script_pattern, '', stripped, flags=re_flags)
            stripped = strip_string(stripped)
            txt += stripped
    return html.unescape(txt)


# Load configuration
config_file = CONFIG_FILENAME
config = configparser.ConfigParser()
config.clear()
config.read(config_file)

# Begin processing

# log in to lists.icos-ri.eu:
payload = {"login": config['mm_settings']['hyperkittyuser'],
           "password": config['mm_settings']['hyperkittypass']}

write_log("Preparing to login to lists.icos-ri.eu")
session = requests.Session()

login_url = 'https://lists.icos-ri.eu/accounts/login/'
token_name = "csrfmiddlewaretoken"
session.headers.update({'Referer': login_url})

res = session.get(login_url)
soup = BeautifulSoup(res.text, 'html.parser')


payload[token_name] = soup.find('input', attrs={"name": token_name})['value']
res = session.post(login_url, data=payload)
soup = BeautifulSoup(res.text, 'html.parser')
if len(soup.select(".alert-success")) == 1:
    write_log("Successfully logged in")
else:
    write_log("Unable to log in!!!")
    raise PermissionError("Unable to log in")

# We should now be successfully logged in, on the session side, so we can
# query Hyperkitty's API for messages

# Use mailman to get lists
# Connect to the mailman list server
client = Client(config['mm_settings']['url'],
                config['mm_settings']['user'],
                config['mm_settings']['pass'])

# Get all lists
all_lists = []
domains = client.domains
for d in domains:
    all_lists = all_lists + [li for li in client.get_domain(d).get_lists()]

# Cut-off date for checking emails
cutoff_date = datetime.now() - timedelta(hours=48)

# filter all_lists to only those that are set to allow emails from the public
# Default action to take when a non-member posts = Accept immediately
# default_nonmember_action = accept
# and archive policy is not never (public or private)
# AND last post was after cutoff_date
lists_to_check = []
for x in all_lists:
    s = x.settings
    if s["last_post_at"]:
        last_post = datetime.strptime(s["last_post_at"],
                                      "%Y-%m-%dT%H:%M:%S.%f")
    else:  # list has no posts
        continue
    if (last_post > cutoff_date
            and s["default_nonmember_action"] == "accept"
            and s["archive_policy"] != "never"):
        lists_to_check.append(x)

write_log(f"Found {str(len(lists_to_check))} lists to check")

# for each list, query API and find all of the emails.
# if you would like to skip lists because they are finished,
# add them (using the list_id) to skip_lists
skip_lists = ["exbo.eric-forum.eu"]

# make a timezone aware cutoff_date, for comparison with email sent time
cutoff_date_aware = cutoff_date.astimezone(timezone.utc)
total_email_requests = 0
all_spam_ids = []


for mlist in lists_to_check:
    address = mlist.fqdn_listname
    if mlist.list_id in skip_lists:
        write_log(f"Skipping list {address}")
        continue
    write_log("Beginning processing of " + address)

    # Can now use lists to query API and find all of the emails
    r = session.get('https://lists.icos-ri.eu/hyperkitty/api/list/'
                    + address
                    + '/emails/')

    list_emails = json.loads(r.content)

    write_log(f"Retrieved {len(list_emails)} emails from {address}.")

    if len(list_emails) == 0:
        write_log("No emails, no processing required.")
        continue

    spam_list = []
    ham_list = []

    time_bert = 0
    time_langid = 0
    time_translate = 0
    last_time = time.time()
    first_stop = 0

    for e in list_emails:
        # do not process email if sent before cutoff_date
        d = e["date"]
        sent_time = datetime.strptime(e["date"], "%Y-%m-%dT%H:%M:%S%z")
        if sent_time < cutoff_date_aware:
            # Emails are listed in reverse chronological order,
            # so we do not have to check later emails for the cutoff_date --
            # they are all past it and do not need to be checked
            break
        total_email_requests += 1

        email = json.loads(session.get(e["url"]).content)
        txt = process_email(email, session)
        short_text = txt[0:1000]
        # identify language
        t_start = time.time()
        lang = identify_language(short_text)
        time_langid += time.time() - t_start
        # if in German, translate
        if lang == "de":
            t_start = time.time()
            short_text = translate_g2e(short_text)
            delta_translate = time.time() - t_start
            time_translate += delta_translate
        t_start = time.time()
        spam_bert = is_spam_bert(short_text)
        time_bert += (time.time() - t_start)
        message_tuple = (e["message_id"], email["subject"], short_text)
        if spam_bert:
            all_spam_ids.append([e["message_id"]])
            spam_list.append(message_tuple)
        else:
            ham_list.append(message_tuple)

    write_log(f"{address} - Spam: {len(spam_list)}; Ham: {len(ham_list)} ")
    write_log(f"{address} - Bert time: {time_bert}; Translation time: "
              + f"{time_translate}; LangID time: {time_langid}")

# write updated translation cache
write_cache_file()
write_log(f"Total email requests = {total_email_requests}")
write_log(f"Total spam to delete: {len(all_spam_ids)}")

# Output to all_spam_ids.csv
with open(SPAM_IDS_FILE, 'w', newline='', encoding='utf-8') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerows(all_spam_ids)

write_log(f"Wrote spam IDs to file: {SPAM_IDS_FILE}")
total_execution_time = time.time() - total_execution_time_start
write_log(f"Total execution time: {total_execution_time} seconds")
