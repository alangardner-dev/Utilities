
import argparse
import os
import re
import requests
from bs4 import BeautifulSoup

# It is recommended to install the required libraries in a virtual environment:
# pip install requests beautifulsoup4

def fetch_website_content(url):
    """Fetches the content of a website from a URL."""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
        }
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Raise an exception for bad status codes
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error fetching the URL: {e}")
        return None

def extract_content_and_title(html_content):
    """Extracts the main text content and title from HTML."""
    if not html_content:
        return None, "untitled"
    soup = BeautifulSoup(html_content, 'html.parser')
    
    title = soup.title.string if soup.title else "untitled"

    # Try to find the main content by looking for article, main, or body tags
    if soup.article:
        main_content = soup.article
    elif soup.main:
        main_content = soup.main
    else:
        main_content = soup.body

    # Remove script and style elements
    for script_or_style in main_content(['script', 'style']):
        script_or_style.decompose()
        
    # Get text
    text = main_content.get_text()
    
    # Break into lines and remove leading and trailing space on each
    lines = (line.strip() for line in text.splitlines())
    # Break multi-headlines into a line each
    chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
    # Drop blank lines
    text = '\n'.join(chunk for chunk in chunks if chunk)
    
    return text, title

def to_kebab_case(text):
    """Converts a string to kebab case."""
    text = str(text).strip().lower()
    text = re.sub(r'[\s_-]+', '-', text)
    text = re.sub(r'[^a-z0-9-]', '', text)
    return text

def save_content_to_file(directory, title, content):
    """Saves the extracted content to a text file in the specified directory."""
    if not content:
        print("No content to save.")
        return
        
    if not os.path.exists(directory):
        try:
            os.makedirs(directory)
        except OSError as e:
            print(f"Error creating directory {directory}: {e}")
            return
            
    # Create a valid filename from the title
    kebab_title = to_kebab_case(title)
    filename = f"{kebab_title}.txt"
    filepath = os.path.join(directory, filename)
    
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Content saved to {filepath}")
    except IOError as e:
        print(f"Error writing to file {filepath}: {e}")

def main():
    """Main function to orchestrate the script."""
    parser = argparse.ArgumentParser(description='Scrape the main text content of a website.')
    parser.add_argument('url', help='The URL of the website to scrape.')
    parser.add_argument('directory', help='The directory to save the scraped text file.')
    
    args = parser.parse_args()
    
    html_content = fetch_website_content(args.url)
    if html_content:
        main_content, title = extract_content_and_title(html_content)
        save_content_to_file(args.directory, title, main_content)

if __name__ == "__main__":
    main()
