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
  kitty bash -c "$HOME/dotfiles/scripts/rofi/systemmenu/update.sh"
  ;;
"󰏗  Install")
  kitty bash -c "$HOME/dotfiles/scripts/rofi/systemmenu/install.sh"
  ;;
"  Remove")
  kitty bash -c "$HOME/dotfiles/scripts/rofi/systemmenu/remove.sh"
  ;;
"  Screenshot")
  if [[ "$session" == *"hyprland"* ]]; then
    "$HOME/dotfiles/scripts/rofi/screenshot-hypr.sh"
  elif [[ "$session" == *"niri"* ]]; then
    "$HOME/dotfiles/scripts/rofi/screenshot-niri.sh"
  else
    "$HOME/dotfiles/scripts/rofi/screenshot-hypr.sh"
  fi
  ;;
"  Wallpaper")
  "$HOME/dotfiles/scripts/rofi/walpicker-pywal.sh"
  ;;
"  Power")
  "$HOME/dotfiles/scripts/rofi/powermenu.sh"
  ;;
*)
  exit 0
  ;;
esac
