#!/bin/bash

if pgrep -x "waybar" >/dev/null; then
  pkill waybar
  sleep 1

  if pgrep -x "waybar" >/dev/null; then
    killall -9 waybar
    echo "Waybar was stubborn, force-killed it."
    sleep 0.5
  fi
else
  echo "Waybar not running, starting it."
fi

waybar &
disown

echo "Waybar restarted."
