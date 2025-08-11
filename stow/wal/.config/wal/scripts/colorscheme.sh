#!/bin/bash

# Directories where pywal stores user-defined schemes
DARK_DIR="$HOME/.config/wal/colorschemes/dark"
LIGHT_DIR="$HOME/.config/wal/colorschemes/light"
COLOR_SYMLINK="$HOME/.config/wal/current_colorscheme"
WALL_SYMLINK="$HOME/.config/wal/current_wallpaper"

# Merge both into one temp list, removing .json extension
SCHEME_LIST=$(mktemp)
find "$DARK_DIR" "$LIGHT_DIR" -type f -name "*.json" -printf "%P\n" 2>/dev/null |
  sed 's/\.json$//' >"$SCHEME_LIST"

# Handle spaces in filenames
IFS=$'\n'

# Show Rofi menu
SELECTED_SCHEME=$(cat "$SCHEME_LIST" | rofi -dmenu -p "Choose Colorscheme:" -i)

rm "$SCHEME_LIST"

# Exit if nothing chosen
[ -z "$SELECTED_SCHEME" ] && {
  echo "No colorscheme selected. Exiting."
  exit 0
}

# Add .json back to match the actual file
if [ -f "$DARK_DIR/$SELECTED_SCHEME.json" ]; then
  SCHEME_PATH="$DARK_DIR/$SELECTED_SCHEME.json"
elif [ -f "$LIGHT_DIR/$SELECTED_SCHEME.json" ]; then
  SCHEME_PATH="$LIGHT_DIR/$SELECTED_SCHEME.json"
else
  echo "Scheme not found."
  exit 1
fi

# Apply the chosen scheme
/home/allanabiud/.local/bin/wal --theme "$SCHEME_PATH" -n

# Get wallpaper from scheme JSON
WALLPAPER_PATH=$(jq -r '.wallpaper' "$SCHEME_PATH")

# If wallpaper exists, set it with swww
if [ -f "$WALLPAPER_PATH" ]; then
  swww img "$WALLPAPER_PATH" --transition-type grow --transition-pos top-right --transition-step 90
fi

# Restart Dunst with new colors
cp "$HOME/.cache/wal/dunstrc" "$HOME/.config/dunst/dunstrc"
pkill dunst && sleep 0.5 && dunst &

# Recolor Telegram
walogram

# Create symlinks for current colorscheme and wallpaper
mkdir -p "$(dirname "$COLOR_SYMLINK")"
ln -sf "$SCHEME_PATH" "$COLOR_SYMLINK"

mkdir -p "$(dirname "$WALL_SYMLINK")"
if [ -f "$WALLPAPER_PATH" ]; then
  ln -sf "$WALLPAPER_PATH" "$WALL_SYMLINK"
fi

# Notify
SCHEME_NAME=$(basename "$SCHEME_PATH" .json)
dunstify -i "$WALLPAPER_PATH" -a "Pywal" "Colorscheme Changed" "$SCHEME_NAME"
