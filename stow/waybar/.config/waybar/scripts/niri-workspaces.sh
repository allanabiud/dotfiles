#!/bin/bash

declare -A ICONS=(
  ["DEV"]=""
  ["Web"]=""
  ["File Management"]=""
  ["Multimedia"]=""
  ["Documents"]=""
  ["Messaging"]=""
  ["Gaming"]=""
  ["Misc"]=""
)

readarray -t ws_lines < <(niri msg workspaces | grep '^[[:space:]]*[0-9]')
readarray -t win_lines < <(niri msg windows | grep 'Workspace ID')

declare -A WS_COUNTS
for line in "${win_lines[@]}"; do
  ws_id=$(echo "$line" | grep -o '[0-9]*$')
  ((WS_COUNTS[$ws_id]++))
done

text=""
tooltip=""
has_windows=false

for line in "${ws_lines[@]}"; do
  ws_id=$(echo "$line" | awk '{print $1}')
  ws_name=$(echo "$line" | cut -d'"' -f2)
  [[ -z "$ws_name" ]] && ws_name="unnamed"
  count=${WS_COUNTS[$ws_id]:-0}
  icon=${ICONS[$ws_name]:-}

  text+="$icon [$count] "
  tooltip+="$ws_name ($count)\n"

  ((count > 0)) && has_windows=true
done

text="${text% }"
tooltip="${tooltip%\\n}"

# Output JSON manually
printf '{ "text": "%s", "alt": "workspace-status", "tooltip": "%s", "class": [%s] }\n' \
  "$text" "$tooltip" "$($has_windows && echo '"has-windows"' || echo)"
