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
    "$HOME/.config/scripts/rofi/screenshot-hypr.sh"
  elif [[ "$session" == *"niri"* ]]; then
    "$HOME/.config/scripts/rofi/screenshot-niri.sh"
  else
    "$HOME/.config/scripts/rofi/screenshot-hypr.sh"
  fi
  ;;
"  Wallpaper")
  "$HOME/.config/scripts/rofi/walpicker-pywal.sh"
  ;;
"  Power")
  "$HOME/.config/scripts/rofi/powermenu.sh"
  ;;
*)
  exit 0
  ;;
esac
