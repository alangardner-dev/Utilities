#!/bin/bash

## VARIABLES
IMAGE_DIRECTORY="$1"
IMAGE_WIDTH="$2"
DEFAULT_IMAGE_WIDTH=1280
MAX_WIDTH="${IMAGE_WIDTH:-DEFAULT_IMAGE_WIDTH}"


## VALIDATION
if [[ ! -d $IMAGE_DIRECTORY ]]; then
  echo "$IMAGE_DIRECTORY is not a valid directory path."
  exit 1
fi

if [[ ! $IMAGE_WIDTH =~ ^[0-9]+$ ]]; then
  echo "$IMAGE_WIDTH is not a valid number."
  exit 1
fi

## FUNCTIONS
check_dependency() {
  local command_name="$1"
  if ! command -v "$command_name" &> /dev/null; then
    echo "$command_name is not installed. Please install it."
    exit 1
  fi
}

get_total_size() {
    du -sh "$1" | cut -f1
}

convert_to_bytes() {
  local size_with_unit="$1"
  local unit="${size_with_unit: -1}"
  local size="${size_with_unit%?}"

  case "$unit" in
    K|k)
      echo "$(echo "$size * 1024" | bc)"
      ;;
    M|m)
      echo "$(echo "$size * 1024 * 1024" | bc)"
      ;;
    G|g)
      echo "$(echo "$size * 1024 * 1024 * 1024" | bc)"
      ;;
    *)
      echo "${size//[^0-9]}"
      ;;
  esac
}


convert_to_human_readable() {
  local bytes="$1"

  if [ $(echo "$bytes < 1024" | bc) -eq 1 ]; then
    echo "${bytes}B"
  elif [ $(echo "$bytes < 1024 * 1024" | bc) -eq 1 ]; then
    echo "$(echo "scale=2; $bytes / 1024" | bc)KB"
  elif [ $(echo "$bytes < 1024 * 1024 * 1024" | bc) -eq 1 ]; then
    echo "$(echo "scale=2; $bytes / 1024 / 1024" | bc)MB"
  else
    echo "$(echo "scale=2; $bytes / 1024 / 1024 / 1024" | bc)GB"
  fi
}

check_dependency "jpegoptim"
check_dependency "mogrify"
check_dependency "gifsicle"
check_dependency "pngquant"
check_dependency "magick" "convert"
check_dependency "cwebp"

image_dir_initial_size=$(get_total_size "$IMAGE_DIRECTORY")
echo "Start time: $(date +"%Y-%m-%d %H:%M:%S")"
echo "Initial Size: $image_dir_initial_size"
echo ""

find "$IMAGE_DIRECTORY" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif -o -iname \*.webp \) | while read -r image; do
    width=$(identify -format "%w" "$image")


    if [ "$width" -gt "$MAX_WIDTH" ]; then
        if [[ "$image" =~ \.jpe?g$ ]]; then
            convert "$image" -resize "$MAX_WIDTH"x -quality 90% "$image"
        else
            mogrify -resize "$MAX_WIDTH"x "$image"
        fi

        if [[ "$image" =~ \.png$ ]]; then
            pngquant --force --ext .png --skip-if-larger -- "$image"
        elif [[ "$image" =~ \.gif$ ]]; then
            gifsicle --optimize=3 --output="$image" "$image"
        elif [[ "$image" =~ \.jpe?g$ ]]; then
            jpegoptim --max=80 --strip-all "$image"
        elif [[ "$image" =~ \.webp$ ]]; then
            if command -v magick &> /dev/null; then
                magick "$image" -resize "$MAX_WIDTH"x -quality 90% "$image"
            else
                convert "$image" -resize "$MAX_WIDTH"x -quality 90% "$image"
            fi
        fi

        echo ""
        echo "Resized and optimized: $image"
    else
        echo ""
        echo "Optimizing a smaller image: $image"

        if [[ "$image" =~ \.png$ ]]; then
            pngquant --force --ext .png --skip-if-larger -- "$image"
        elif [[ "$image" =~ \.gif$ ]]; then
            gifsicle --optimize=3 --output="$image" "$image"
        elif [[ "$image" =~ \.jpe?g$ ]]; then
            jpegoptim --max=80 --strip-all "$image"
        elif [[ "$image" =~ \.webp$ ]]; then
          if command -v magick &> /dev/null; then
              magick "$image" -resize "$MAX_WIDTH"x -quality 90% "$image"
          else
            convert "$image" -quality 80% "$image"
          fi
        fi
    fi
done

image_dir_final_size=$(get_total_size "$IMAGE_DIRECTORY")
echo ""
echo "Image resizing and optimization completed."
echo "End time: $(date +"%Y-%m-%d %H:%M:%S")"
echo ""

dir_size_before=$(convert_to_bytes "$image_dir_initial_size")
dir_size_after=$(convert_to_bytes "$image_dir_final_size")
result=$(echo "$dir_size_before - $dir_size_after" | bc)

echo "Initial Size: $image_dir_initial_size"
echo "  Final Size: $image_dir_final_size"
echo "   You saved: $(convert_to_human_readable $result)"
