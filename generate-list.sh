#!/bin/bash
# Run this script after adding new images to any category folder.
# It updates the image registry in index.html automatically.
# Usage: bash generate-list.sh

CATEGORIES=("body" "dress" "hats" "shoes" "accessories")

for cat in "${CATEGORIES[@]}"; do
  folder="images/$cat"
  files=""
  if [ -d "$folder" ]; then
    for f in "$folder"/*.{png,jpg,jpeg,webp,gif} 2>/dev/null; do
      [ -f "$f" ] || continue
      filename=$(basename "$f")
      files="${files}\"${filename}\", "
    done
    files="${files%, }"  # remove trailing comma
  fi

  # Replace the registry entry for this category in index.html
  sed -i "s|${cat}:        \[.*\]|${cat}:        [${files}]|g" index.html
done

echo "Done! Image list updated in index.html"
