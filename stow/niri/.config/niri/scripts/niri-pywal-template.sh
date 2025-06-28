#!/usr/bin/env bash

# Paths
SOURCE_CONFIG="${HOME}/.config/niri/config.kdl"
TEMPLATE_OUTPUT="${HOME}/.config/wal/templates/niri-config.kdl"

echo "🌀  Niri → Pywal Template Generator"

# Check if source config exists
if [[ ! -f "$SOURCE_CONFIG" ]]; then
  echo "❌ Error: Niri config not found at $SOURCE_CONFIG"
  exit 1
fi

# Ensure target directory exists
mkdir -p "$(dirname "$TEMPLATE_OUTPUT")" || {
  echo "❌ Error: Failed to create target directory"
  exit 1
}

echo "📂 Reading:  $SOURCE_CONFIG"
echo "📝 Writing:  $TEMPLATE_OUTPUT"
echo ""

# Process the config
awk '
{
  line = $0

  # Replace known color lines with Pywal variables
  if (line ~ /^\s*active-color\s+"#[0-9a-fA-F]+"$/) {
    sub(/"#[0-9a-fA-F]+"/, "\"{color1}\"", line)
  } else if (line ~ /^\s*inactive-color\s+"#[0-9a-fA-F]+"$/) {
    sub(/"#[0-9a-fA-F]+"/, "\"{color0}\"", line)
  } else if (line ~ /^\s*backdrop-color\s+"#[0-9a-fA-F]+"$/) {
    sub(/"#[0-9a-fA-F]+"/, "\"{color0}\"", line)
  }

  # Escape all curly braces
  gsub("{", "{{", line)
  gsub("}", "}}", line)

  # Restore pywal variable braces
  gsub("{{color0}}", "{color0}", line)
  gsub("{{color1}}", "{color1}", line)

  print line
}
' "$SOURCE_CONFIG" >"$TEMPLATE_OUTPUT"

# Done
echo "✅ Template created at $TEMPLATE_OUTPUT"
echo ""
echo "──────────────────────────────────────────────────────────────────────────────"
echo "✔ active-color    → \"{color1}\""
echo "✔ inactive-color  → \"{color0}\""
echo "✔ backdrop-color  → \"{color0}\""
echo "✔ All other curly braces safely escaped for Pywal template use"
echo "──────────────────────────────────────────────────────────────────────────────"
