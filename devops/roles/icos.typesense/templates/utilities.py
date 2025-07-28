import requests, time, re, hashlib
from bs4 import BeautifulSoup
from datetime import datetime, timedelta

# Configuration and private variables
# NOTE: If website theme or structure changes, ensure the "is_in_main" function continues
# to work; ensure content_id is updated as well!!
base_url = '{{ base_urls[website] }}'

# default to special domain_pattern for icos-cp and icos-ri sites, incl. demo
domain_pattern = re.compile(r'https?://www\.icos\-(ri|cp)\.eu')
if "demo.icos-cp" in base_url:
    domain_pattern = re.compile(r'https?://demo\.icos\-(ri|cp)\.eu')
# otherwise, build domain pattern to allow http or https
elif "icos-cp" not in base_url:
    url_pattern = r'^https?://(?P<host>[^/]+)/?$'
    url_match = re.match(url_pattern, base_url)
    host = re.escape(url_match.groupdict()["host"])
    domain_pattern = re.compile(r'https?://' + host)

file_pattern = re.compile(r'.*\.\w\w\w?\w?$')
media_pattern = re.compile(r'.*media/[0-9]+$')

matomo_api_key = "{{ vault_matomo_api_key }}"
matomo_site_id = "2"

## Utility functions
def url_to_id(url):
    return hashlib.sha256(url.encode('utf-8')).hexdigest()

def is_in_main(link):
    if link.parent is None:
        return False
    if link.parent.get("id") == "main":
        return True
    return is_in_main(link.parent)

# unused, but may be useful in the future
def is_in_menu(url, soup):
    url_path = url[len(base_url)-1:]
    for menu_url in soup.find_all("a"):
        if menu_url.href == url or menu_url.href == url_path:
            return True
    return False

def strip_query_and_anchor(url):
    stripped_url = url
    for x in "?#":
        if x in stripped_url:
            stripped_url = stripped_url[0:stripped_url.index(x)]
    return stripped_url

def get_soup_with_iframes(text: str) -> BeautifulSoup:
    soup = BeautifulSoup(text, "html.parser")
    for iframe in soup.find_all("iframe"):
        # make separate request for iframe
        iframe_req = requests.get(iframe.get("src"))
        iframe.insert(0, BeautifulSoup(iframe_req.text, "html.parser"))
    #pprint.pprint(soup)
    return soup

def get_page_content(soup: BeautifulSoup):
    main_content = soup.select("main")[0]
    # Remove elements with style="display: none"
    for tag in main_content.find_all(style=True):
        # check if tag parent is none; this indicates the tag parent has been destroyed so this tag is also "destroyed"
        if tag.parent is None:
            continue
        style = tag['style'].replace(" ", "").lower()
        if "display:none" in style:
            tag.decompose()
    tags_to_unwrap = ['em', 'strong', 'sub', 'sup', 'span', 'a']
    for tag in main_content.find_all(tags_to_unwrap):
        tag.unwrap()
    texts_raw = main_content.get_text(separator="\n", strip=True).split("\n")
    # remove > symbol at start of strings
    texts = []
    for t in texts_raw:
        if t.startswith(">"):
            texts.append(t[1:].strip())
        else:
            texts.append(t.strip())
    return "\n".join(texts)

def get_links_on_page(soup, current_url):
    links_on_page = []
    for link in soup.find_all('a'):
        href = link.get('href')

        if href is None:
            href = "None"
        elif href.startswith("/") and not href.startswith("//"):
            # make href an absolute ref instead of relative.
            # base_url ends with a /, so remove the beginning slash from href
            href = base_url + href[1:]
        elif href.startswith("?"):
            # make href an absolute ref instead of query by stripping any query
            # or anchor tags off current_url and then appending href.
            # this allows for us to check, e.g. "/news?page=1" for links to
            # "/news?page=4" without accidentally building "/news?page=1?page=4"
            # which makes no sense
            href = strip_query_and_anchor(current_url) + href
        elif href.startswith("#"):
            # process correctly for all_links, then
            # filter out anchors before adding to to_check_urls
            href = current_url + href

        add_href = href
        if (file_pattern.match(add_href) is not None
                or media_pattern.match(add_href) is not None):
            # skip, as this is a file (or "media", drupal uploaded files)
            continue

        if "#" in add_href:
            # do not consider anchor links as unique
            add_href = add_href[0:add_href.index("#")]

        if (domain_pattern.match(add_href) is not None):
            links_on_page.append(add_href)
    return links_on_page

def timestamp():
    return datetime.today().strftime('%Y-%m-%d %H:%M:%S ')

## Main functions for importing
def update_page(doc, verbose=False):
    url = doc["url"]
    head = requests.head(url)
    updated_doc = {"id": doc["id"], "url": doc["url"]}
    doc_status = {"changed": False, "doc": updated_doc}
    if not head.headers["Content-Type"].startswith("text/html"):
        print(timestamp() + "[update_page] Non-HTML document found at " + url)
        return doc_status
    if (head.status_code == 200 and "etag" in head.headers and "etag" in doc):
        prev_etag = doc["etag"]
        curr_etag = head.headers["etag"]
        if prev_etag == curr_etag:
            return doc_status
        else:
            updated_doc["etag"] = curr_etag
    elif head.status_code == 301:
        print(timestamp() + "[update_page] Redirect from " + url)
        doc_status["status"] = 301
        doc_status["dest"] = head.headers["location"]
        return doc_status
    elif head.status_code != 200:
        print(timestamp() + "[update_page] Non-200 status (HEAD): " + url + " with status=" + str(head.status_code))
        doc_status["status"] = head.status_code
        return doc_status
    elif "etag" in head.headers:
        # etag in response but not in doc, add to doc
        updated_doc["etag"] = head.headers["etag"]
    doc_status["changed"] = True
    # either no etag found OR page has changed
    resp = requests.get(url)
    if resp.status_code != 200:
        print(timestamp() + "[update_page] Non-200 status (GET): " + url + " with status=" + str(head.status_code))
        doc_status["status"] = resp.status_code
        return doc_status
    soup = get_soup_with_iframes(resp.text)
    updated_doc["title"] = soup.find("h1", attrs={"class":"page-title"}).text
    doc_status["links"] = get_links_on_page(soup, url)
    updated_doc["content"] = get_page_content(soup)
    return doc_status


def get_all_pages(verbose=False):
    checked_urls = list()
    to_check_urls = list()
    to_check_urls.append(base_url)
    final_urls = set()
    unique_urls = set()

    all_errors = list()
    all_pages = list()
    url_seen = {}

    while len(to_check_urls) > 0:
        current_url = to_check_urls.pop()
        if current_url not in url_seen:
            url_seen[current_url] = 0
        checked_urls.append(current_url)
        if not current_url.startswith("http"):
            all_errors.append((current_url, "malformed"))
            print(timestamp() + "[get_all_pages] Malformed URL: " + current_url)
            continue

        # if processing is really fast, enable time.sleep to rate limit
        # however, with the nav link recursion, this is not going to happen now...
        time.sleep(0)
        reqs = requests.get(current_url)
        status = reqs.status_code
        if status != 200:
            print(timestamp() + "[get_all_pages] Non-200 status: " + current_url + " with status=" + str(status))
            all_errors.append((current_url, "status " + str(status)))
            continue
        if len(reqs.history) > 0 and (reqs.history[0].status_code == 301
                                    or reqs.history[0].status_code == 308):
            if verbose:
                print(timestamp() + "[get_all_pages] Redirect from " + current_url)
            redirected_url = reqs.url
            unique_urls.add(redirected_url)
            if (domain_pattern.match(redirected_url) is not None
                    and redirected_url not in checked_urls
                    and redirected_url not in to_check_urls):
                to_check_urls.append(redirected_url)
            continue
        if not reqs.headers["Content-Type"].startswith("text/html"):
            print(timestamp() + "[get_all_pages] Non-HTML document found at " + current_url)
            all_errors.append((current_url, "non-html content-type: " + str(reqs.headers["Content-Type"])))
            continue

        unique_urls.add(reqs.url)
        soup = get_soup_with_iframes(reqs.text)
        skip_index = False

        # do not index front page; its contents change regularly and are not needed to find in search
        if (current_url is base_url
                or current_url is (base_url + "news")
                or "?" in current_url):
            skip_index = True

        links_on_page = get_links_on_page(soup, current_url)

        for link in links_on_page:
            if link in url_seen:
                url_seen[link] += 1
            else:
                url_seen[link] = 1
            if link not in checked_urls and link not in to_check_urls:
                to_check_urls.append(link)
        if verbose:
            print(timestamp() + f"[get_all_pages] Finished {current_url}\n"
                + timestamp() + f"[get_all_pages] Checked {len(checked_urls)} URLs.\n"
                + timestamp() + f"[get_all_pages] Have {len(to_check_urls)} to go.\n")

        # add to all_pages unless skip_index
        if not skip_index:
            page = {}
            page["url"] = current_url
            page["etag"] = reqs.headers["etag"] if "etag" in reqs.headers else None
            page["title"] = soup.find("h1", attrs={"class":"page-title"}).text
            page["content"] = get_page_content(soup)
            all_pages.append(page)

        final_urls.add(current_url)
    #for page in all_pages:
    #    times_seen = 0
    #    if page["url"] in url_seen:
    #        times_seen = url_seen[page["url"]]
    #    else:
    #        print("Error counting times seen for URL = " + page["url"])
    #    page["num_times_linked"] = times_seen
    return all_pages

def get_analytics():
    # Get analytics data
    if matomo_site_id == "0":
        return {} # SITES, use Plausible API

    today = datetime.today().strftime('%Y-%m-%d')
    one_year_ago = (datetime.today() - timedelta(days=365)).strftime('%Y-%m-%d')

    # prepare to match analytics data with typesense data

    # get analytics data
    matomo_token = matomo_api_key

    matomo_url = ("https://matomo.icos-cp.eu/?"
                    + "module=API&"
                    + "method=Actions.getPageUrls&"
                    + "idSite=" + matomo_site_id + "&"
                    + "period=range&"
                    + "date=" + one_year_ago + "," + today + "&"
                    + "module=API&"
                    + "format=json&"
                    + "showColumns=nb_visits&"
                    + "flat=1&"
                    + "filter_limit=-1&" #can use filter_limit and filter_offset for pagination
                    # limit to Europe and NA to avoid bot traffic
                    + "continentCode==eur,continentCode==amn&"
                    + "token_auth=" + matomo_token
                )

    matomo_req = requests.get(matomo_url)

    url_data = matomo_req.json()

    url_views = {}
    for page in url_data:
        url_views[page["label"]] = page["nb_visits"]
    return url_views
