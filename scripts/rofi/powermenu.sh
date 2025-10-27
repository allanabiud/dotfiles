#! /bin/bash

lock=''
lock_cmd='hyprlock'

suspend='󰒲'
suspend_cmd='systemctl suspend'

logout='󰍃'
logout_cmd="loginctl terminate-user $USER"

reboot=''
reboot_cmd='systemctl reboot'

shutdown=''
shutdown_cmd='systemctl poweroff'

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

rofi_cmd() {
  rofi \
    -theme ~/.config/rofi/themes/powermenu.rasi \
    -dmenu \
    -sep ',' \
    -p "Uptime: $uptime" \
    -mesg "Uptime: $uptime"
}

run_rofi() {
  printf "$lock,$suspend,$logout,$reboot,$shutdown" | rofi_cmd
}

case "$(run_rofi)" in
$lock) ${lock_cmd} ;;
$suspend) ${suspend_cmd} ;;
$logout) ${logout_cmd} ;;
$reboot) ${reboot_cmd} ;;
$shutdown) ${shutdown_cmd} ;;
esac
