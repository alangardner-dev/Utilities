# Scrape Website Text

This Python script scrapes the main text content from a given URL and saves it into a text file. The filename is generated from the title of the webpage, converted to kebab case.

## Features

- Fetches HTML content from a URL.
- Identifies the main content of a webpage by looking for `<article>`, `<main>`, or `<body>` tags.
- Extracts and cleans the text content, removing scripts, styles, and extra whitespace.
- Saves the cleaned text to a file with a kebab-case name derived from the webpage's title (e.g., "My Awesome Page" becomes `my-awesome-page.txt`).
- Includes a `User-Agent` header to mimic a browser and avoid 403 errors.

## Requirements

- Python 3
- `requests` library
- `beautifulsoup4` library

## Installation

1.  **Clone the repository or download the script.**

2.  **Navigate to the script directory:**
    ```bash
    cd /path/to/scrape-website-text
    ```

3.  **It is highly recommended to use a virtual environment:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

4.  **Install the required libraries using the `requirements.txt` file:**
    ```bash
    pip install -r requirements.txt
    ```

## Usage

Run the script from the command line, providing the URL of the website to scrape and the directory where you want to save the output file.

```bash
python scrape-website-text.py <URL> <directory_path>
```

### Arguments

-   `<URL>`: The full URL of the webpage you want to scrape.
-   `<directory_path>`: The path to the directory where the text file will be saved. If the directory doesn't exist, the script will create it.

## Example

```bash
python scrape-website-text.py "https://en.wikipedia.org/wiki/Python_(programming_language)" ./output
```

This command will:
1.  Fetch the content from the Wikipedia page for the Python programming language.
2.  Extract the main article text.
3.  Create a directory named `output` if it doesn't already exist.
4.  Save the content to a file named `python-programming-language.txt` inside the `output` directory.
