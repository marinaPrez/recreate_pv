#!/bin/bash

# Loop through all .yaml files in the current directory
for file in *.yaml; do
  if [[ -f "$file" ]]; then
    echo "Applying $file"
    kubectl apply -f "$file"
    if [[ $? -eq 0 ]]; then
      echo "Successfully applied $file"
    else
      echo "Failed to apply $file"
    fi
  fi
done
