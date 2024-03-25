#!/bin/bash

parent_dir=$1

log_file="$parent_dir/git_status.log"
temp_file="$parent_dir/git_status_sorted.log"

for dir in "$parent_dir"/*; do
    if [ -d "$dir/.git" ]; then
        echo "Checking $dir..."
        cd "$dir" || exit

        git_status=$(git status)

        if [[ "$git_status" != *"nothing to commit, working tree clean"* ]]; then
            echo "UPDATE: $dir" >> "$log_file"
        fi
    else
        echo "Not git project: $dir" >> "$log_file"
    fi
done

sort "$log_file" > "$temp_file"
mv "$temp_file" "$log_file"
