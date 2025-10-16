#!/bin/bash

# Disable exit on error
set +e

# wallpaper daemon
swww-daemon &

# waybar
waybar &

# dunst
dunst &

# networkmanager
nm-applet &

# blueman
blueman-applet &

# mpDris2
mpDris2 &

# pywal
wal -R &
