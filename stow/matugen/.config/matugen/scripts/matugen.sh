#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
SYMLINK_PATH="$HOME/.config/wal/current_wallpaper"

cd "$WALLPAPER_DIR" || {
  echo "Error: Wallpaper directory not found at $WALLPAPER_DIR"
  exit 1
}

#  handle spaces in filenames
IFS=$'\n'

# display wallpapers in rofi
SELECTED_WALL=$(for img in $(ls -t *.jpg *.png *.gif *.jpeg 2>/dev/null); do
  echo -en "$img\0icon\x1f$img\n"
done | rofi -dmenu -p "Choose Wallpaper:" -i)

# get selected wallpaper
[ -z "$SELECTED_WALL" ] && {
  echo "No wallpaper selected. Exiting."
  exit 0
}

# get wallpaper path
WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

# generate colorscheme & set wallpaper
matugen image "$WALLPAPER_PATH"
/home/allanabiud/.local/bin/wal --contrast 2.5 --saturate 0.6 -i "$WALLPAPER_PATH" -b "#000000" -n

# create symlink
mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$WALLPAPER_PATH" "$SYMLINK_PATH"

# notify
dunstify -i "$WALLPAPER_PATH" -a "Pywal" "Wallpaper Changed" "Wallpaper: $SELECTED_WALL"
