#!/bin/bash

# Hyprland monitor layout selector using hyprctl and rofi-wayland

CONFIG="$HOME/.config/hypr/hyprland.conf"
TMP_CONF="$HOME/.config/hypr/monitors-autogen.conf"
BACKUP="$CONFIG.bak"

# --- Helpers ---
get_monitors() {
  hyprctl monitors | awk '/Monitor/ { print $2 }'
}

select_with_rofi() {
  prompt="$1"
  shift
  printf "%s\n" "$@" | rofi -dmenu -p "$prompt"
}

apply_config() {
  cat "$TMP_CONF" >>"$CONFIG"
  hyprctl reload
  notify-send "Hyprland" "Monitor layout applied"
}

gen_only_config() {
  primary="$1"
  {
    echo "# Hyprland Auto Monitor Config"
    for mon in "${MONITORS[@]}"; do
      if [[ "$mon" == "$primary" ]]; then
        echo "monitor=$mon,preferred,auto,1"
      else
        echo "monitor=$mon,disable"
      fi
    done
  } >"$TMP_CONF"
}

gen_dual_config() {
  main="$1"
  side="$2"
  {
    echo "# Hyprland Auto Monitor Config"
    echo "monitor=$main,preferred,auto,1"
    echo "monitor=$side,preferred,auto,1,left of $main"
  } >"$TMP_CONF"
}

gen_clone_config() {
  main="$1"
  mirror="$2"
  {
    echo "# Hyprland Auto Monitor Config"
    echo "monitor=$main,preferred,auto,1"
    echo "monitor=$mirror,preferred,auto,1,same as $main"
  } >"$TMP_CONF"
}

# --- Main ---
readarray -t MONITORS < <(get_monitors)

if [[ ${#MONITORS[@]} -eq 0 ]]; then
  notify-send "Hyprland" "No monitors detected"
  exit 1
fi

# Build menu
ENTRIES=("Cancel")
COMMANDS=("true")

# Only one monitor
for i in "${!MONITORS[@]}"; do
  ENTRIES+=("Only ${MONITORS[i]}")
  COMMANDS+=("gen_only_config ${MONITORS[i]}")
done

# Dual setup
for i in "${!MONITORS[@]}"; do
  for j in "${!MONITORS[@]}"; do
    [[ $i -eq $j ]] && continue
    ENTRIES+=("Dual Screen: ${MONITORS[i]} -> ${MONITORS[j]}")
    COMMANDS+=("gen_dual_config ${MONITORS[i]} ${MONITORS[j]}")
  done
done

# Clone
for i in "${!MONITORS[@]}"; do
  for j in "${!MONITORS[@]}"; do
    [[ $i -eq $j ]] && continue
    ENTRIES+=("Clone ${MONITORS[j]} to ${MONITORS[i]}")
    COMMANDS+=("gen_clone_config ${MONITORS[i]} ${MONITORS[j]}")
  done
done

# Show menu
MENU=$(printf "%s\n" "${ENTRIES[@]}" | rofi -dmenu -p "Monitor Layout")
[[ -z "$MENU" || "$MENU" == "Cancel" ]] && exit

# Find and execute matching command
for i in "${!ENTRIES[@]}"; do
  if [[ "${ENTRIES[i]}" == "$MENU" ]]; then
    eval "${COMMANDS[i]}"
    cp "$CONFIG" "$BACKUP"
    apply_config
    exit
  fi
done
