#!/bin/bash

## VARIABLES
IMAGE_DIRECTORY="$1"
IMAGE_WIDTH="$2"
DEFAULT_IMAGE_WIDTH=1280

## VALIDATION
# Verify the path provided exists
if [[ ! -d $IMAGE_DIRECTORY ]]; then
  echo "$IMAGE_DIRECTORY is not a valid directory path."
  exit 1
fi

if [[ ! $IMAGE_WIDTH =~ ^[0-9]+$ ]]; then
  echo "$IMAGE_WIDTH is not a valid number."
  exit 1
fi
 
# Function to check if a command is available
check_dependency() {
  local command_name="$1"
  if ! command -v "$command_name" &> /dev/null; then
    echo "$command_name is not installed. Please install it."
    # You can add additional logic here, such as exiting the script or taking appropriate actions.
  fi
}

# Check dependencies
check_dependency "jpegoptim"
check_dependency "mogrify"
check_dependency "gifsicle"
check_dependency "pngquant"


# Use Provided width or default
MAX_WIDTH="${IMAGE_WIDTH:-DEFAULT_IMAGE_WIDTH}"

## FUNCTIONS
# Function to calculate the total size of all files in a directory
get_total_size() {
    du -sh "$1" | cut -f1
}

# Function to remove the unit and convert to bytes
# input: a value from get_total_size
convert_to_bytes() {
  local size_with_unit="$1"
  local unit="${size_with_unit: -1}"  # Get the last character (unit)
  local size="${size_with_unit%?}"    # Remove the last character (unit)
  
  case "$unit" in
    K)
      echo $((size * 1024))
      ;;
    M)
      echo $((size * 1024 * 1024))
      ;;
    G)
      echo $((size * 1024 * 1024 * 1024))
      ;;
    *)
      echo "$size"  # Assume it's already in bytes if no unit
      ;;
  esac
}

# Function to convert bytes to human-readable format
convert_to_human_readable() {
  local bytes="$1"

#   echo "bytes is $bytes"

  if ((bytes < 1024)); then
    echo "${bytes}B"
  elif ((bytes < 1024 * 1024)); then
    echo "$((bytes / 1024))KB"
  elif ((bytes < 1024 * 1024 * 1024)); then
    echo "$((bytes / 1024 / 1024))MB"
  else
    echo "$((bytes / 1024 / 1024 / 1024))GB"
  fi
}

# Get the initial size of the IMAGE_DIRECTORY
initial_size=$(get_total_size "$IMAGE_DIRECTORY")
echo "Start time: $(date +"%Y-%m-%d %H:%M:%S")"
echo "Initial Size: $initial_size"
echo ""

# Iterate through each image in the directory
find "$IMAGE_DIRECTORY" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif \) | while read -r image; do
    # Get the image's width
    width=$(identify -format "%w" "$image")

    # Check if the image width is greater than the maximum width
    if [ "$width" -gt "$MAX_WIDTH" ]; then
        # Resize the image to the maximum width and reduce quality (JPEG/JPG only)
        if [[ "$image" =~ \.jpe?g$ ]]; then
            convert "$image" -resize "$MAX_WIDTH"x -quality 80% "$image"
        else
            # For PNG and GIF, just resize without changing the format
            mogrify -resize "$MAX_WIDTH"x "$image"
        fi

        # Optimize PNG images using pngquant
        if [[ "$image" =~ \.png$ ]]; then
            pngquant --force --ext .png --skip-if-larger -- "$image"
        fi

        # Optimize GIF images using gifsicle
        if [[ "$image" =~ \.gif$ ]]; then
            gifsicle --optimize=3 --output="$image" "$image"
        fi

        # Optimize JPEG/JPG images using jpegoptim (optional)
        if [[ "$image" =~ \.jpe?g$ ]]; then
            jpegoptim --max=80 --strip-all "$image"
        fi

        echo "Resized and optimized: $image"
    else
        echo "Optimizing a smaller image: $image"
        # Optimize PNG images using pngquant
        if [[ "$image" =~ \.png$ ]]; then
            pngquant --force --ext .png --skip-if-larger -- "$image"
        fi

        # Optimize GIF images using gifsicle
        if [[ "$image" =~ \.gif$ ]]; then
            gifsicle --optimize=3 --output="$image" "$image"
        fi

        # Optimize JPEG/JPG images using jpegoptim (optional)
        if [[ "$image" =~ \.jpe?g$ ]]; then
            jpegoptim --max=80 --strip-all "$image"
        fi
    fi
done

# Get the final size of the IMAGE_DIRECTORY
final_size=$(get_total_size "$IMAGE_DIRECTORY")

echo "Image resizing and optimization completed."
echo ""
echo "End time: $(date +"%Y-%m-%d %H:%M:%S")"
echo ""
Dir_size_before=$(convert_to_bytes "$initial_size")
Dir_size_after=$(convert_to_bytes "$final_size")
result=$((Dir_size_before - Dir_size_after))
echo "Initial Size: $initial_size"
echo "Final Size:   $final_size"
echo "You saved:     $(convert_to_human_readable $result)"
