#!/bin/bash

WALLPAPER="$1"

# Apply colorscheme with pywal16
/home/allanabiud/.local/bin/wal --contrast 2.5 --saturate 0.6 -i "$WALLPAPER"

# walogram (telegram pywal16 colorscheme)
walogram

# dunst
cp /home/allanabiud/.cache/wal/dunstrc /home/allanabiud/.config/dunst/dunstrc
pkill dunst && dunst &

# Restart waybar to apply new theme
pkill waybar && waybar &

# Tell Hyprland to reload its config (to apply new colors)
hyprctl reload

notify-send "✅ Wallpaper and colorscheme changed"
