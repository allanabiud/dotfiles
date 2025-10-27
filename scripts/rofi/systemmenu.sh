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
  ~/dotfiles/scripts/rofi/screenshot-niri.sh
  ;;
"  Wallpaper")
  ~/dotfiles/scripts/rofi/walpicker-pywal.sh
  ;;
"  Power")
  ~/dotfiles/scripts/rofi/powermenu.sh
  ;;
*)
  exit 0
  ;;
esac
