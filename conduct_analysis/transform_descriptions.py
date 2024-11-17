import string
import nltk
from nltk.corpus import stopwords
from collections import Counter
import csv
import pandas as pd

# Download necessary NLTK resources
nltk.download("punkt_tab")
nltk.download("stopwords")

# Set of English stopwords
stop_words = set(stopwords.words("english"))


def tokenize_and_count(text: str) -> Counter:
    """Tokenizes the text, removes punctuation, stopwords, downcases, and counts word frequencies.

    Args:
        text (str): String to tokenize.

    Returns:
        Counter: A Counter object with counts of words
    """
    # Remove punctuation and downcase
    text = text.translate(str.maketrans("", "", string.punctuation)).lower()

    # Tokenize the text
    tokens = nltk.word_tokenize(text)

    # Remove stop words
    filtered_tokens = [word for word in tokens if word not in stop_words]

    # Count the word frequencies
    word_counts = Counter(filtered_tokens)

    return word_counts


def get_word_counts_for_crash(plane_data: pd.DataFrame) -> dict:
    """Takes an array of episode objects and calculates word frequencies for each.

    Args:
        plane_data (pd.DataFrame): Dataframe with plane crash information.

    Returns:
        dict: Dict of index number of crash + Counter of word information
    """
    summary_word_counts = {}

    i = 1
    for plane_desc in list(plane_data["Summary"]):
        # Tokenize the text and count word frequencies
        if not pd.isna(plane_desc):
            word_counts = tokenize_and_count(plane_desc)

            # Store the word counts for each episode
            summary_word_counts[i] = word_counts

        i += 1

    return summary_word_counts


def get_total_word_count(summary_word_counts: dict) -> dict:
    """Calculates the total word count across all episodes.

    Args:
        summary_word_counts (dict): A dictionary object of crashes and descriptions.

    Returns:
        dict: Updated count with all words.
    """
    total_word_count = Counter()

    for word_counts in summary_word_counts.values():
        total_word_count.update(word_counts)

    return total_word_count


def convert_to_word_count_vectors(episode_word_counts, filtered_words):
    """Converts word counts for each episode into a vector following the filtered word order."""
    word_vectors = {}

    for url, word_counts in episode_word_counts.items():
        # Create a vector for this episode by the order of filtered_words
        vector = [word_counts.get(word, 0) for word in filtered_words]
        word_vectors[url] = vector

    return word_vectors


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


if __name__ == "__main__":
    # Open cleaned dataset
    plane_data = pd.read_csv("cleaned_data/cleaned_data.csv")

    # Calculate total word counts
    plane_desc_counts = get_word_counts_for_crash(plane_data)

    # Calculate total word count over all crashes
    total_word_count = get_total_word_count(plane_desc_counts)

    # Filter words with a total count greater than 20 and sort by frequency
    filtered_words = [word for word, count in total_word_count.items() if count > 20]

    # Convert each episode's word counts into a vector of word counts
    word_count_vectors = convert_to_word_count_vectors(
        episode_word_counts, filtered_words
    )

    # Write the word count vectors to a CSV file
    write_word_counts_to_csv(word_count_vectors, filtered_words)

    print("Word counts written to 'episode_word_counts.csv'")
