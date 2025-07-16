#!/bin/bash

# Check if the path is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/your/directory_or_image"
  exit 1
fi

# Set the input path from the first argument
INPUT_PATH="$1"

# Function to convert an image to .webp
convert_to_webp() {
  file="$1"
  ext="${file##*.}"
  base="${file%.*}"
  cwebp "$file" -o "${base}.webp"
  echo "Converted $file to ${base}.webp"
}

# Check if the input path is a directory
if [ -d "$INPUT_PATH" ]; then
  # Iterate through all jpg, jpeg, png, and gif files in the directory
  for file in "$INPUT_PATH"/*.{jpg,jpeg,png,gif}; do
    # Check if the file exists (in case there are no matching files)
    if [ -f "$file" ]; then
      convert_to_webp "$file"
    fi
  done

# Check if the input path is a file
elif [ -f "$INPUT_PATH" ]; then
  # Get the file extension
  ext="${INPUT_PATH##*.}"
  # Check if the file is an image
  if [[ "$ext" =~ ^(jpg|jpeg|png|gif)$ ]]; then
    convert_to_webp "$INPUT_PATH"
  else
    echo "Error: File $INPUT_PATH is not a supported image format."
    exit 1
  fi

# If the input path is neither a directory nor a file
else
  echo "Error: $INPUT_PATH does not exist."
  exit 1
fi
