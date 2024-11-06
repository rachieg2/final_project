import os
import hashlib
from random import randint
import pandas as pd
from tqdm import tqdm
from time import sleep
from urllib.error import HTTPError
from pandas.errors import EmptyDataError


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


def fetch(url: str) -> pd.DataFrame:
    """Get flight tables and save them in a cached-file, if they exist.

    Args:
        url (str): URL to parse.

    Returns:
        pd.DataFrame: The flight information found.
    """
    cache_file = cache_path(url)

    # Check if the page is cached
    if os.path.exists(cache_file):
        with open(cache_file, "r", encoding="utf-8") as file:
            try:
                return pd.read_csv(cache_file, sep=",")
            except EmptyDataError:
                return None

    # If not cached, fetch the table and cache it
    try:
        sleep(randint(2, 5))
        page_content = pd.read_html(
            url, flavor="bs4", encoding="latin-1", header=0, index_col=0, na_values="?"
        )[0]
    except HTTPError as err:
        # This isn't a real URL
        if "404" in str(err):
            page_content = None
        else:
            print(err)
            return None
    if page_content is not None:
        # Fix content
        page_content = page_content.transpose()
        page_content.reset_index(drop=True, inplace=True)
        page_content.columns = [i.replace(":", "") for i in list(page_content)]
        page_content.to_csv(cache_file, index=None, sep=",", mode="w")
        return page_content
    else:
        page_content = ""
        with open(cache_file, "w", encoding="utf-8") as file:
            file.write(page_content)
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


def get_plane_crash_data() -> pd.DataFrame:
    """Return all plane crash data from the plane crash database.

    Returns:
        pd.DataFrame: All plane crash data, formatted.
    """

    urls = get_all_plane_crash_urls()

    all_planes = pd.DataFrame()

    for url in tqdm(urls):
        plane_data = fetch(url)
        if plane_data is not None:
            all_planes = pd.concat([all_planes, plane_data])

    return all_planes


def save_plane_data(
    plane_data: pd.DataFrame,
    save_folder: str = "data",
    save_name: str = "plane_data.csv",
):
    """Save the plane data as a csv.

    Args:
        plane_data (pd.DataFrame): Full dataframe of plane infromation.
        save_folder (str, optional): Path to folder where to save the data. Defaults to "data".
        save_name (str, optional): Name of the csv to save. Defaults to "plane_data.csv".
    """
    os.makedirs(save_folder, exist_ok=True)
    plane_data.reset_index(drop=True)
    plane_data.to_csv(os.path.join(save_folder, save_name), index=False)


# Get all plane crash information
plane_data = get_plane_crash_data()
save_plane_data(plane_data)
