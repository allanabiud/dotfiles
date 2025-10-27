#!/bin/bash

# ==============================
#  INSTALL SCRIPT
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
echo -e "║        INSTALL OPTIONS             ║"
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
  echo -e "\n${cyan}==> Fetching package list...${reset}"
  pkg=$(pacman -Slq | fzf --prompt="Select Arch package: " \
    --preview 'pacman -Si {} 2>/dev/null' --preview-window=up:60%)
  if [[ -n "$pkg" ]]; then
    echo -e "${cyan}\n==> Installing $pkg...${reset}"
    sudo pacman -S "$pkg"
    echo -e "${green}✓ Installation complete.${reset}"
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

  pkg=$($aur_helper -Slq aur | fzf --prompt="Select AUR package: " \
    --preview "$aur_helper -Si {} 2>/dev/null" --preview-window=up:60%)
  if [[ -n "$pkg" ]]; then
    echo -e "${cyan}\n==> Installing $pkg with $aur_helper...${reset}"
    "$aur_helper" -S "$pkg"
    echo -e "${green}✓ Installation complete.${reset}"
  else
    echo -e "${red}✗ No package selected.${reset}"
  fi
  ;;

# ========== 3. WEB APP ==========
3)
  echo -e "\n${cyan}==> Create a Web App${reset}"
  echo -ne "${yellow}Enter Web App Name: ${reset}"
  read -r app_name
  [[ -z "$app_name" ]] && echo -e "${red}✗ Name is required.${reset}" && exit 1

  echo -ne "${yellow}Enter Web App URL: ${reset}"
  read -r app_url
  [[ -z "$app_url" ]] && echo -e "${red}✗ URL is required.${reset}" && exit 1

  echo -ne "${yellow}Enter Icon Path or URL (optional): ${reset}"
  read -r app_icon

  desktop_file="$apps_dir/${app_name,,}.desktop"

  # If icon is a URL, attempt to download it
  if [[ "$app_icon" =~ ^https?:// ]]; then
    icon_path="$icons_dir/${app_name,,}.png"
    echo -e "${cyan}Downloading icon...${reset}"
    curl -L -o "$icon_path" "$app_icon" 2>/dev/null || {
      echo -e "${red}✗ Failed to download icon.${reset}"
      icon_path="$icons_dir/default.png"
    }
  elif [[ -f "$app_icon" ]]; then
    icon_path="$app_icon"
  else
    icon_path="$icons_dir/default.png"
  fi

  # Write desktop file
  cat >"$desktop_file" <<EOF
[Desktop Entry]
Name=$app_name
Exec=vivaldi --app=$app_url
Terminal=false
Type=Application
Icon=$icon_path
Categories=WebApps;
EOF

  chmod +x "$desktop_file"
  update-desktop-database ~/.local/share/applications &>/dev/null

  echo -e "\n${green}✓ Web App '$app_name' created successfully!${reset}"
  echo -e "Saved to: ${cyan}$desktop_file${reset}"
  ;;

*)
  echo -e "${red}✗ Invalid choice. Exiting.${reset}"
  exit 1
  ;;
esac

echo -e "\n${yellow}Press Enter to exit.${reset}"
read -r
