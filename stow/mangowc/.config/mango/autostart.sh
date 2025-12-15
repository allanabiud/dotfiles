#!/bin/bash

# Disable exit on error
set +e

# wallpaper daemon
swww-daemon &

# waybar
waybar &

# dunst
# dunst &

# mako
mako

# networkmanager
nm-applet &

# blueman
blueman-applet &

# mpDris2
mpDris2 &

# pywal
wal -R &

# pcmanfm daemon
# pcmanfm --daemon-mode &

# hypridle
hypridle &

# Clipboard Manager
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store

# Polkit agent
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# xdg-desktop-portal-wlr
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
