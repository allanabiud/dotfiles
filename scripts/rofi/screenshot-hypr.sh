#!/bin/bash

# Icons
region=''
window=''
screen='󰹑'

# Commands
region_cmd='hyprshot -m region'
window_cmd='hyprshot -m window'
screen_cmd='hyprshot -m output -m LVDS-1'

# Rofi theme (reuse your existing powermenu theme if you like)
rofi_theme="~/.config/rofi/themes/screenshot.rasi"

# Rofi command setup
rofi_cmd() {
  rofi \
    -theme "$rofi_theme" \
    -dmenu \
    -sep ',' \
    -p "Screenshot" \
    -mesg "Select screenshot option:"
}

# Display the menu
run_rofi() {
  printf "$region,$window,$screen" | rofi_cmd
}

# Run selection
case "$(run_rofi)" in
$region) ${region_cmd} ;;
$window) ${window_cmd} ;;
$screen) ${screen_cmd} ;;
esac
