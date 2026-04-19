#!/bin/bash
# Run this script after adding new images to any category folder.
# It updates the image registry in index.html automatically.
# Usage: bash generate-list.sh

CATEGORIES=("body" "dress" "hats" "shoes" "accessories")

for cat in "${CATEGORIES[@]}"; do
  folder="images/$cat"
  files=""
  if [ -d "$folder" ]; then
    for f in "$folder"/*.png "$folder"/*.jpg "$folder"/*.jpeg "$folder"/*.webp "$folder"/*.gif; do
      [ -f "$f" ] || continue
      filename=$(basename "$f")
      files="${files}\"${filename}\", "
    done
    files="${files%, }"  # remove trailing comma+space
  fi

  # Use perl for reliable replacement — handles any spacing and optional trailing comma
  perl -i -pe "s|(\Q${cat}\E:\s*\[)[^\]]*(\],?)|\${1}${files}\${2}|g" index.html
done

echo "Done! Image list updated in index.html"
