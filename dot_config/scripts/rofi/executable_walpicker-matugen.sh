#!/bin/bash

# === CONFIG ===
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/thumbnails/walpicker"
SYMLINK_PATH="$HOME/.config/wal/current_wallpaper"
ROFI_THEME="$HOME/.config/rofi/themes/walpicker.rasi"
MATUGEN_BIN="matugen"
PYWAL_BIN="$HOME/.local/bin/wal"

# Ensure directories exist
mkdir -p "$WALLPAPER_DIR" "$CACHE_DIR" "$(dirname "$SYMLINK_PATH")"

# === GENERATE THUMBNAILS ===
find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \) | while read -r image; do
  filename="$(basename "$image")"
  thumb="$CACHE_DIR/$filename"
  if [ ! -f "$thumb" ]; then
    # Generate a thumbnail, preserve aspect ratio, crop/resize to 262x540
    magick convert -strip "$image" -thumbnail x540^ -gravity center -extent 262x540 "$thumb"
  fi
done

# === ROFI MENU (with thumbnails) ===
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

# Generate colors with matugen
"$MATUGEN_BIN" image "$WALLPAPER_PATH"

# Also generate pywal colors (optional, keeps compatibility)
# "$PYWAL_BIN" --contrast 2.5 --saturate 0.6 -i "$WALLPAPER_PATH" -b "#000000" -n

# Create symlink to current wallpaper
ln -sf "$WALLPAPER_PATH" "$SYMLINK_PATH"

# === NOTIFY ===
notify-send -i "$WALLPAPER_PATH" -a "Matugen" "Wallpaper Changed" "Wallpaper: $SELECTED_WALL"
