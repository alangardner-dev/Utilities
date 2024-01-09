#!/bin/bash

npm install -D tailwindcss
npx tailwindcss init

search_directory="."
file_to_find="index.css"
text_to_prepend="@tailwind base;
@tailwind components;
@tailwind utilities;
"

# Insert Tailwind directives into top of index.css
find "$search_directory" -type f -name "$file_to_find" -exec sh -c 'echo "$0" | cat - "$1" > temp && mv temp "$1"' "$text_to_prepend" {} \;
