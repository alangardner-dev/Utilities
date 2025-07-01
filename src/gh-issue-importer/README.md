# GitHub Issues Creator

This script creates GitHub issues in bulk from a CSV file using the GitHub API.

## Prerequisites

- Python 3.7+
- A GitHub personal access token (with `repo` scope)

## Setup

1. **Clone this repository** (or download the script and CSV file).

2. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

3. **Create a `.env` file** in the project directory with your GitHub token:

   ```env
   GITHUB_TOKEN=your_personal_access_token_here
   ```

   > You can create a token at: https://github.com/settings/tokens

4. **Prepare your CSV file** (see below for format).

## CSV Format

The CSV file should have the following columns:

- `title` (required): The issue title
- `body` (optional): The issue description
- `assignee` (optional): GitHub username to assign
- `label` (optional): Comma-separated labels or a JSON array of labels

Example:

```csv
title,body,assignee,label
"Bug: Crash on load","App crashes when loading.","octocat","bug,urgent"
"Feature: Add dark mode","Please add a dark mode option.",,"[\"enhancement\", \"UI\"]"
```

## Usage

Run the script with the following command:

```bash
python github_issues_creator.py <OWNER> <REPO> <CSV_FILE>
```

- `<OWNER>`: GitHub organization or username (e.g., `{account or username}`)
- `<REPO>`: Repository name (e.g., `{repo-name}`)
- `<CSV_FILE>`: Path to your CSV file (e.g., `{csv_file_name}.csv`)

**Example:**

```bash
python github_issues_creator.py {account or username} {repo-name} {csv_file_name}.csv
```

The script will prompt for confirmation before creating issues.

## Notes

- The script checks for GitHub API rate limits and waits if necessary.
- Errors and successes are printed to the console.
- Make sure your token has the correct permissions for the target repository.

## License

MIT 