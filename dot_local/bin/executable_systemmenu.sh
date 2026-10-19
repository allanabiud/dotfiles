#!/bin/bash

# -------- Menu Options -------- #
options=(
  "  Update"
  "󰏗  Install"
  "  Remove"
  "  Screenshot"
  "  Wallpaper"
  "  Power"
)

# -------- Rofi Menu -------- #
choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Main Menu" -theme ~/.config/rofi/themes/systemmenu.rasi)

# -------- Detect Session -------- #
session=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

# -------- Menu Actions -------- #
case "$choice" in
"  Update")
  kitty bash -c "$HOME/.config/scripts/rofi/systemmenu/update.sh"
  ;;
"󰏗  Install")
  kitty bash -c "$HOME/.config/scripts/rofi/systemmenu/install.sh"
  ;;
"  Remove")
  kitty bash -c "$HOME/.config/scripts/rofi/systemmenu/remove.sh"
  ;;
"  Screenshot")
  if [[ "$session" == *"hyprland"* ]]; then
    screenshot-hypr.sh
  elif [[ "$session" == *"niri"* ]]; then
    screenshot-niri.sh
  else
    screenshot-hypr.sh
  fi
  ;;
"  Wallpaper")
  walpicker-pywal.sh
  ;;
"  Power")
  powermenu.sh
  ;;
*)
  exit 0
  ;;
esac
