import string
import nltk
from nltk.corpus import stopwords
from collections import Counter
import csv

# Download necessary NLTK resources
nltk.download("punkt")
nltk.download("stopwords")

# Set of English stopwords
stop_words = set(stopwords.words("english"))


def tokenize_and_count(text):
    """Tokenizes the text, removes punctuation, stopwords, downcases, and counts word frequencies."""
    # Remove punctuation and downcase
    text = text.translate(str.maketrans("", "", string.punctuation)).lower()

    # Tokenize the text
    tokens = nltk.word_tokenize(text)

    # Remove stop words
    filtered_tokens = [word for word in tokens if word not in stop_words]

    # Count the word frequencies
    word_counts = Counter(filtered_tokens)

    return word_counts


def get_text_of_episodes():
    """Fetches and returns an array of objects with episode URLs and their text."""
    urls = episode_list_urls()
    episodes = []

    for url in urls:
        bs = fetch(url)
        b = bs.find("tbody")
        txt = b.text

        # Store the URL and text in an object (dictionary) for each episode
        episodes.append({"url": url, "text": txt})

    return episodes


def get_word_counts_for_episodes(episodes):
    """Takes an array of episode objects and calculates word frequencies for each."""
    episode_word_counts = {}

    for episode in episodes:
        url = episode["url"]
        text = episode["text"]

        # Tokenize the text and count word frequencies
        word_counts = tokenize_and_count(text)

        # Store the word counts for each episode
        episode_word_counts[url] = word_counts

    return episode_word_counts


def get_total_word_count(episode_word_counts):
    """Calculates the total word count across all episodes."""
    total_word_count = Counter()

    for word_counts in episode_word_counts.values():
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
