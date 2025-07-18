#!/bin/bash

WALLPAPER="$1"

# Apply colorscheme with pywal16
/home/allanabiud/.local/bin/wal --contrast 2.5 --saturate 0.6 -i "$WALLPAPER" -b "#000000"

# Niri
cp "${HOME}/.cache/wal/niri-config.kdl" "${HOME}/.config/niri/config.kdl"

# walogram (telegram pywal16 colorscheme)
walogram

# dunst
cp /home/allanabiud/.cache/wal/dunstrc /home/allanabiud/.config/dunst/dunstrc
pkill dunst && sleep 0.5 && dunst &

# Wait briefly for everything to settle (important!)
sleep 0.5

# Smooth Waybar restart
if pgrep -x "waybar" >/dev/null; then
  pkill waybar
  sleep 1 # Let it fully shut down before relaunching
fi
waybar &
disown

# Tell Hyprland to reload its config (to apply new colors)
# hyprctl reload

dunstify -i "$WALLPAPER" -a "pywal" "🎨 Colorscheme Applied" "$WALLPAPER"
