#!/bin/bash

# ==============================
#  REMOVE SCRIPT
#  Options: Arch, AUR, Web App
# ==============================

set -e

# Colors
cyan="\e[1;36m"
yellow="\e[1;33m"
green="\e[1;32m"
red="\e[1;31m"
reset="\e[0m"

# Directories
apps_dir="$HOME/.local/share/applications/web-apps"
icons_dir="$HOME/.local/share/icons/web-apps"
mkdir -p "$apps_dir" "$icons_dir"

# Menu
clear
echo -e "${cyan}╔════════════════════════════════════╗"
echo -e "║          REMOVE OPTIONS            ║"
echo -e "╠════════════════════════════════════╣"
echo -e "║  [1] Arch Package (Pacman)         ║"
echo -e "║  [2] AUR Package (Yay/Paru)        ║"
echo -e "║  [3] Web App                       ║"
echo -e "╚════════════════════════════════════╝"
echo -ne "${yellow}Select option (1-3): ${reset}"
read -r choice

case "$choice" in
# ========== 1. ARCH PACKAGE ==========
1)
  echo -e "\n${cyan}==> Fetching installed Arch packages...${reset}"
  pkg=$(pacman -Qq | fzf --prompt="Select package to remove: " \
    --preview 'pacman -Qi {} 2>/dev/null' --preview-window=up:60%)
  if [[ -n "$pkg" ]]; then
    echo -e "${cyan}\n==> Removing $pkg...${reset}"
    sudo pacman -Rns "$pkg"
    echo -e "${green}✓ $pkg removed successfully.${reset}"
  else
    echo -e "${red}✗ No package selected.${reset}"
  fi
  ;;

# ========== 2. AUR PACKAGE ==========
2)
  echo -e "\n${cyan}==> Checking for AUR helper...${reset}"
  if command -v yay &>/dev/null; then
    aur_helper="yay"
  elif command -v paru &>/dev/null; then
    aur_helper="paru"
  else
    echo -e "${red}✗ No AUR helper (yay/paru) found!${reset}"
    exit 1
  fi

  echo -e "${cyan}==> Fetching installed AUR packages...${reset}"
  pkg=$($aur_helper -Qm | awk '{print $1}' | fzf --prompt="Select AUR package to remove: " \
    --preview "$aur_helper -Qi {} 2>/dev/null" --preview-window=up:60%)
  if [[ -n "$pkg" ]]; then
    echo -e "${cyan}\n==> Removing $pkg with $aur_helper...${reset}"
    "$aur_helper" -Rns "$pkg"
    echo -e "${green}✓ $pkg removed successfully.${reset}"
  else
    echo -e "${red}✗ No package selected.${reset}"
  fi
  ;;

# ========== 3. WEB APP ==========
3)
  echo -e "\n${cyan}==> Select Web App to Remove${reset}"
  app_file=$(ls "$apps_dir"/*.desktop 2>/dev/null | fzf --prompt="Select Web App: " --preview "cat {}")
  if [[ -z "$app_file" ]]; then
    echo -e "${red}✗ No web app selected.${reset}"
    exit 0
  fi

  app_name=$(grep -m1 '^Name=' "$app_file" | cut -d'=' -f2)
  app_icon=$(grep -m1 '^Icon=' "$app_file" | cut -d'=' -f2)

  echo -e "${yellow}Remove '$app_name'? (y/n): ${reset}"
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -f "$app_file"
    [[ -f "$app_icon" && "$app_icon" == "$icons_dir/"* ]] && rm -f "$app_icon"
    update-desktop-database ~/.local/share/applications &>/dev/null
    echo -e "${green}✓ Web App '$app_name' removed successfully.${reset}"
  else
    echo -e "${red}✗ Cancelled.${reset}"
  fi
  ;;

*)
  echo -e "${red}✗ Invalid choice. Exiting.${reset}"
  exit 1
  ;;
esac

echo -e "\n${yellow}Press Enter to close...${reset}"
read -r
