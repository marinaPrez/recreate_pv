#!/bin/bash

# Loop through all .yaml files in the current directory
for file in *.yaml; do
  if [[ -f "$file" ]]; then
    echo "Processing $file"
    # Use sed to delete lines beginning with creationTimestamp, uid, or resourceVersion (with optional leading spaces)
    sed -i '' '/^[[:space:]]*creationTimestamp:/d' "$file"
    sed -i '' '/^[[:space:]]*uid:/d' "$file"
    sed -i '' '/^[[:space:]]*resourceVersion:/d' "$file"
    # Use sed to comment out lines starting with claimRef and the next 4 lines (with optional leading spaces)
    sed -i '' '/^[[:space:]]*claimRef/,+4 s/^/# /' "$file"
    echo "Updated $file"
  else
    echo "No .yaml files found in the current directory."
  fi
done
