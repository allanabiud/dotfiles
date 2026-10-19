#!/bin/bash

# -------- Ask which updater to use -------- #
clear
echo -e "\e[1;36m╔════════════════════════════════════╗"
echo -e "║   Choose update method             ║"
echo -e "╠════════════════════════════════════╣"
echo -e "║  [1] Pacman (official repos)       ║"
echo -e "║  [2] Yay (official repos + AUR)    ║"
echo -e "╚════════════════════════════════════╝"
echo -ne "\e[1;33mSelect option (1/2): \e[0m"
read -r choice

# -------- Run selected update -------- #
case "$choice" in
1)
  echo -e "\n\e[1;36m==> Updating system using Pacman...\e[0m"
  echo "----------------------------------------"
  sudo pacman -Syu
  echo
  echo -e "\e[1;32m✓ Pacman update complete!\e[0m"
  ;;
2)
  if command -v yay &>/dev/null; then
    echo -e "\n\e[1;36m==> Updating system using Yay...\e[0m"
    echo "----------------------------------------"
    yay -Syu
    echo
    echo -e "\e[1;32m✓ Yay update complete!\e[0m"
  else
    echo -e "\e[1;31m✗ Yay is not installed!\e[0m"
  fi
  ;;
*)
  echo -e "\e[1;31m✗ Invalid choice. Exiting.\e[0m"
  exit 1
  ;;
esac

echo -e "\n\e[1;37mPress Enter to exit.\e[0m"
read -r
