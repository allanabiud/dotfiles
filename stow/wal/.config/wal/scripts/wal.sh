#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
SYMLINK_PATH="$HOME/.config/wal/current_wallpaper"

cd "$WALLPAPER_DIR" || {
  echo "Error: Wallpaper directory not found at $WALLPAPER_DIR"
  exit 1
}

IFS=$'\n'

SELECTED_WALL=$(for img in $(ls -t *.jpg *.png *.gif *.jpeg 2>/dev/null); do
  echo -en "$img\0icon\x1f$img\n"
done | rofi -dmenu -p "Choose Wallpaper:" -i)

[ -z "$SELECTED_WALL" ] && {
  echo "No wallpaper selected. Exiting."
  exit 0
}

WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED_WALL"

/home/allanabiud/.local/bin/wal --contrast 2.5 --saturate 0.6 -i "$WALLPAPER_PATH" -b "#000000" -n

swww img "$(cat "${HOME}/.cache/wal/wal")" --transition-type grow --transition-pos top-right --transition-step 90

mkdir -p "$(dirname "$SYMLINK_PATH")"
ln -sf "$WALLPAPER_PATH" "$SYMLINK_PATH"

# telegram colorscheme
walogram

# dunst
cp /home/allanabiud/.cache/wal/dunstrc /home/allanabiud/.config/dunst/dunstrc
pkill dunst && sleep 0.5 && dunst &

hyprctl reload

dunstify -i "$WALLPAPER_PATH" -a "Pywal" "Wallpaper Changed" "Wallpaper: $SELECTED_WALL"
