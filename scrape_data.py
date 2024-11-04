import os
import time
import random
import hashlib
import pandas as pd
import requests
from bs4 import BeautifulSoup as BS
import csv
from tqdm import tqdm
from time import sleep
from urllib.error import HTTPError


CACHE_DIR = "page_cache"

# Create the cache directory if it doesn't exist
if not os.path.exists(CACHE_DIR):
    os.makedirs(CACHE_DIR)


def md5_hash(url):
    """Returns the MD5 hash of a given URL."""
    return hashlib.md5(url.encode()).hexdigest()


def cache_path(url):
    """Returns the cache file path for a given URL."""
    return os.path.join(CACHE_DIR, md5_hash(url))


def fetch_raw(url):
    """Fetches the page content from the web without caching."""
    headers = {
        "User-Agent": "curl/7.68.0",  # Mimic the curl request
        "Accept-Language": "en-US,en;q=0.5",
    }

    try:
        time.sleep(random.uniform(2, 4))  # Random delay to avoid hammering the server
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            return response.text
        else:
            print(f"Failed to fetch {url} with status code {response.status_code}")
            return None
    except requests.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return None


def fetch(url):
    """Wrapper function that implements caching around the raw fetch."""
    cache_file = cache_path(url)

    # Check if the page is cached
    if os.path.exists(cache_file):
        with open(cache_file, "r", encoding="utf-8") as file:
            print(f"Loading cached page for {url}")
            return BS(file.read(), "html.parser")

    # If not cached, fetch the table and cache it
    try:
        page_content = pd.read_html(url, flavor="bs4", encoding="latin-1")
    except HTTPError as err:
        if "404" in str(err):
            return None
        else:
            raise err
        # This isn't a rea URL
        return None
    if page_content:
        with open(cache_file, "w", encoding="utf-8") as file:
            file.write(page_content)
        return BS(page_content, "html.parser")
    else:
        return None


def get_all_plane_crash_urls() -> list:
    """Gets all URLs for plane crash data to scrape.

    Returns:
        list: A list of all urls to parse with all plane crash info.
    """
    source_url = "https://www.planecrashinfo.com/database.htm"

    # Get overall years
    all_years = pd.read_html(source_url, flavor="bs4")[1]
    all_years = all_years.values.tolist()
    all_years = [x for xs in all_years for x in xs]
    all_years = [i for i in all_years if (isinstance(i, int) | isinstance(i, float))]
    all_years = [i for i in all_years if not pd.isnull(i)]
    all_years = [int(i) for i in all_years]

    urls = []
    for yrs in tqdm(all_years):
        sleep(2)
        # Now, we need to get all the sub-urls from a year.
        new_url = source_url.replace("database", f"{yrs}/{yrs}")
        try:
            year_data = pd.read_html(new_url, flavor="bs4", encoding="latin-1")
            if len(year_data) != 1:
                raise ValueError(f"There is more than one table in the {yrs} page.")
            year_data = year_data[0].reset_index()
            for idx_ in list(year_data["index"]):
                urls.append(source_url.replace("database", f"{yrs}/{yrs}-{idx_}"))
        except ValueError:
            # For some reason, pandas can't find a table.
            # So, make urls with 100 possibilities - more than any possible year
            for idx_ in list(range(1, 100)):
                urls.append(source_url.replace("database", f"{yrs}/{yrs}-{idx_}"))
    return urls


def get_plane_crash_data():
    """Fetches and returns an array of objects with episode URLs and their text."""
    urls = get_all_plane_crash_urls()
    episodes = []

    for url in urls:
        bs = fetch(url)
        b = bs.find("tbody")
        txt = b.text

        # Store the URL and text in an object (dictionary) for each episode
        episodes.append({"url": url, "text": txt})

    return episodes


def write_word_counts_to_csv(
    word_count_vectors, filtered_words, filename="episode_word_counts.csv"
):
    """Writes the episode word count vectors to a CSV file."""
    with open(filename, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile)

        # Write the header row (episode URL and each word)
        header = ["Episode URL"] + filtered_words
        writer.writerow(header)

        # Write each episode's word count vector
        for url, vector in word_count_vectors.items():
            row = [url] + vector
            writer.writerow(row)


# Example usage to fetch episode texts, get word counts, and calculate total word count
episodes = get_text_of_episodes()
episode_word_counts = get_word_counts_for_episodes(episodes)

# Calculate total word count over all episodes
total_word_count = get_total_word_count(episode_word_counts)

# Filter words with a total count greater than 20 and sort by frequency
filtered_words = [word for word, count in total_word_count.items() if count > 20]

# Convert each episode's word counts into a vector of word counts
word_count_vectors = convert_to_word_count_vectors(episode_word_counts, filtered_words)

# Write the word count vectors to a CSV file
write_word_counts_to_csv(word_count_vectors, filtered_words)

print("Word counts written to 'episode_word_counts.csv'")
