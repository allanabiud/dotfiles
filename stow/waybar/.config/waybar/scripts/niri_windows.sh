#!/bin/bash

# Get current workspace ID and name
current_ws=$(niri msg workspaces | awk '/\*/ { print $2 }')

# Initialize counter
count=0
current_block=""

# Read windows into blocks
while IFS= read -r line; do
  if [[ "$line" =~ ^Window\ ID ]]; then
    current_block="$line"
  else
    current_block+=$'\n'"$line"
  fi

  if [[ -z "$line" ]]; then
    if echo "$current_block" | grep -q "Workspace ID: $current_ws"; then
      count=$((count + 1))
    fi
    current_block=""
  fi
done <<<"$(niri msg windows)"

# Final block check
if echo "$current_block" | grep -q "Workspace ID: $current_ws"; then
  count=$((count + 1))
fi

# If zero windows, output empty text (no number)
if [ "$count" -le 1 ]; then
  echo ""
else
  echo "$count"
fi
