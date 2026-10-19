#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/thumbnails/walpicker"
SYMLINK_PATH="$HOME/.config/wal/current_wallpaper"
ROFI_THEME="$HOME/.config/rofi/themes/walpicker.rasi"
PYWAL_BIN="$HOME/.local/bin/wal"

# Ensure directories exist
mkdir -p "$WALLPAPER_DIR" "$CACHE_DIR"

# === GENERATE THUMBNAILS ===
find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | while read -r image; do
  filename="$(basename "$image")"
  thumb="$CACHE_DIR/$filename"
  if [ ! -f "$thumb" ]; then
    magick convert -strip "$image" -thumbnail x540^ -gravity center -extent 262x540 "$thumb"
  fi
done

# # === ROFI MENU (with thumbnails) ===
SELECTED_WALL=$(ls "$WALLPAPER_DIR" | while read -r img; do
  echo -en "$img\x00icon\x1f$CACHE_DIR/$img\n"
done | rofi -dmenu -theme "$ROFI_THEME" -p "Wallpaper" -i)

# Exit if nothing selected
[ -z "$SELECTED_WALL" ] && {
  echo "No wallpaper selected. Exiting."
  exit 0
}

# === APPLY WALLPAPER ===
WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# Generate pywal colors
"$PYWAL_BIN" -i "$WALLPAPER_PATH" -b "#000000" -n --contrast 2.0

# Set wallpaper with swww
swww img "$(cat "${HOME}/.cache/wal/wal")" --transition-type random --transition-step 90

# === SYNC OTHER APPS ===
# Telegram theme (if you use walogram)
walogram

# Mako reload
makoctl reload

# Niri Colors
if [ -f ~/.cache/wal/colors-niri.kdl ]; then
  mkdir -p ~/.config/niri
  cp ~/.cache/wal/colors-niri.kdl ~/.config/niri/modules/colors-niri.kdl
  niri msg load-config-file
fi

# Create symlink to current wallpaper
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$WALLPAPER_PATH" "$SYMLINK_PATH"

# Notification
notify-send -i "$WALLPAPER_PATH" -a "Pywal" "Wallpaper Changed" "Wallpaper: $SELECTED_WALL"
