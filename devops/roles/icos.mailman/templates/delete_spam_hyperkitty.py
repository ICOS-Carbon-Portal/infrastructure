# Delete spam from a list of spam IDs
# Intended to via manage.py runscript command

from hyperkitty.models import Email
import csv

path_prefix = "/opt/mailman-web-data/"
spamid_file = f"{path_prefix}all_spam_ids.csv"
backup_file = f"{path_prefix}email_backup.csv"


def run():
    all_spam_ids = []

    # Get spam emails
    try:
        with open(spamid_file, newline='', encoding="utf-8") as csvfile:
            spam_reader = csv.reader(csvfile, delimiter=',')
            for row in spam_reader:
                all_spam_ids.append(row[0])
    except FileNotFoundError as e:
        raise e

    # Get spam emails from Hyperkitty database
    spam_emails = Email.objects.filter(message_id__in=all_spam_ids)

    # Write all of the information from those messages as a backup measure
    fields = [field.name
              for field in Email._meta.get_fields()
              if not field.is_relation]

    # Write to CSV file
    try:
        with open(backup_file, 'a', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(fields)
            for email in spam_emails:
                writer.writerow([getattr(email, field) for field in fields])
    except Exception as e:
        raise e

    # Delete spam emails
    spam_emails.delete()
