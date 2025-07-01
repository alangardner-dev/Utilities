#!/usr/bin/env python3
"""
GitHub Issues Creator Script
Creates GitHub issues from a CSV file using the GitHub API.

Requirements:
- pip install requests pandas python-dotenv

Usage:
1. Create a .env file with your GitHub token:
   GITHUB_TOKEN=your_personal_access_token_here

2. Run the script:
   python github_issues_creator.py

"""

import csv
import json
import os
import time
import requests
from typing import Dict, List, Optional
from dotenv import load_dotenv
import sys

# Load environment variables
load_dotenv()

class GitHubIssueCreator:
    def __init__(self, token: str, owner: str, repo: str):
        """
        Initialize the GitHub Issue Creator.
        
        Args:
            token: GitHub personal access token
            owner: GitHub organization/user name
            repo: Repository name
        """
        self.token = token
        self.owner = owner
        self.repo = repo
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json"
        }
        
    def create_issue(self, title: str, body: str, assignees: List[str] = None, labels: List[str] = None) -> Optional[Dict]:
        """
        Create a GitHub issue.
        
        Args:
            title: Issue title
            body: Issue body/description
            assignees: List of GitHub usernames to assign
            labels: List of labels to apply
            
        Returns:
            Dict with issue data if successful, None if failed
        """
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues"
        
        data = {
            "title": title,
            "body": body
        }
        
        if assignees:
            data["assignees"] = assignees
            
        if labels:
            data["labels"] = labels
        
        try:
            response = requests.post(url, headers=self.headers, data=json.dumps(data))
            
            if response.status_code == 201:
                issue_data = response.json()
                print(f"✅ Created issue #{issue_data['number']}: {title}")
                return issue_data
            else:
                print(f"❌ Failed to create issue '{title}': {response.status_code} - {response.text}")
                return None
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Request failed for issue '{title}': {e}")
            return None
    
    def get_rate_limit_info(self) -> Dict:
        """Get current rate limit information."""
        url = f"{self.base_url}/rate_limit"
        try:
            response = requests.get(url, headers=self.headers)
            if response.status_code == 200:
                return response.json()
        except requests.exceptions.RequestException as e:
            print(f"⚠️  Could not fetch rate limit info: {e}")
        return {}
    
    def wait_for_rate_limit(self):
        """Wait if we're approaching rate limits."""
        rate_info = self.get_rate_limit_info()
        if rate_info and 'rate' in rate_info:
            remaining = rate_info['rate']['remaining']
            if remaining < 10:  # Wait if less than 10 requests remaining
                reset_time = rate_info['rate']['reset']
                wait_time = reset_time - time.time() + 10  # Add 10 second buffer
                if wait_time > 0:
                    print(f"⏳ Rate limit approaching. Waiting {wait_time:.0f} seconds...")
                    time.sleep(wait_time)

def parse_csv_labels(label_string: str) -> List[str]:
    """
    Parse label string from CSV (handles array format like '["label1", "label2"]').
    
    Args:
        label_string: String representation of labels
        
    Returns:
        List of label strings
    """
    if not label_string or label_string.strip() == '':
        return []
    
    try:
        # Try to parse as JSON array first
        if label_string.startswith('[') and label_string.endswith(']'):
            labels = json.loads(label_string)
            return [str(label) for label in labels]
    except json.JSONDecodeError:
        pass
    
    # Fallback: split by comma and clean up
    labels = [label.strip().strip('"\'') for label in label_string.split(',')]
    return [label for label in labels if label]

def read_csv_file(csv_file_path: str) -> List[Dict]:
    """
    Read issues from CSV file.
    
    Args:
        csv_file_path: Path to the CSV file
        
    Returns:
        List of issue dictionaries
    """
    issues = []
    
    try:
        with open(csv_file_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                # Parse labels
                labels = parse_csv_labels(row.get('label', ''))
                
                # Parse assignees
                assignees = []
                if row.get('assignee') and row['assignee'].strip():
                    assignees = [row['assignee'].strip()]
                
                issue = {
                    'title': row.get('title', '').strip(),
                    'body': row.get('body', '').strip(),
                    'assignees': assignees,
                    'labels': labels
                }
                
                # Skip empty titles
                if issue['title']:
                    issues.append(issue)
                    
    except FileNotFoundError:
        print(f"❌ CSV file not found: {csv_file_path}")
        return []
    except Exception as e:
        print(f"❌ Error reading CSV file: {e}")
        return []
    
    return issues

def main():
    """Main function to create GitHub issues from CSV."""

    # Check for required command-line arguments
    if len(sys.argv) != 4:
        print("❌ Usage: python github_issues_creator.py <OWNER> <REPO> <CSV_FILE>")
        print("   Example: python github_issues_creator.py {your_github_username} {your_repo} {csv_file_name}")
        return

    OWNER = sys.argv[1]
    REPO = sys.argv[2]
    CSV_FILE = sys.argv[3]
    
    # Configuration
    GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
    
    # Validate configuration
    if not GITHUB_TOKEN:
        print("❌ GitHub token not found. Please set GITHUB_TOKEN in your .env file.")
        print("   You can create a token at: https://github.com/settings/tokens")
        print("   Required scopes: repo")
        return
    
    if not os.path.exists(CSV_FILE):
        print(f"❌ CSV file not found: {CSV_FILE}")
        print("   Please make sure the CSV file is in the same directory as this script.")
        return
    
    # Initialize GitHub client
    gh = GitHubIssueCreator(GITHUB_TOKEN, OWNER, REPO)
    
    # Read issues from CSV
    print(f"📖 Reading issues from {CSV_FILE}...")
    issues = read_csv_file(CSV_FILE)
    
    if not issues:
        print("❌ No valid issues found in CSV file.")
        return
    
    print(f"📋 Found {len(issues)} issues to create.")
    
    # Confirm before proceeding
    response = input(f"\n🤔 Create {len(issues)} issues in {OWNER}/{REPO}? (y/N): ")
    if response.lower() not in ['y', 'yes']:
        print("🚫 Operation cancelled.")
        return
    
    # Create issues
    print(f"\n🚀 Creating issues in {OWNER}/{REPO}...")
    created_count = 0
    failed_count = 0
    
    for i, issue in enumerate(issues, 1):
        print(f"\n[{i}/{len(issues)}] Creating: {issue['title'][:60]}...")
        
        # Check rate limits before each request
        gh.wait_for_rate_limit()
        
        # Create the issue
        result = gh.create_issue(
            title=issue['title'],
            body=issue['body'],
            assignees=issue['assignees'],
            labels=issue['labels']
        )
        
        if result:
            created_count += 1
        else:
            failed_count += 1
        
        # Small delay between requests to be respectful
        time.sleep(1)
    
    # Summary
    print(f"\n📊 Summary:")
    print(f"   ✅ Created: {created_count}")
    print(f"   ❌ Failed: {failed_count}")
    print(f"   📝 Total: {len(issues)}")
    
    if created_count > 0:
        print(f"\n🎉 Issues created successfully in https://github.com/{OWNER}/{REPO}/issues")

if __name__ == "__main__":
    main()