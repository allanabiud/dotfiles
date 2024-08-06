# !/bin/bash

# Create directories
mkdir -p ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Videos ~/dotfiles

# Install necessary dependencies
sudo pacman -Syu
sudo pacman -Sy --needed git base-devel stow xss-lock android-tools lazygit ttf-meslo-nerd

# Setup yay
git clone https://aur/archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
rm -rf yay-bin

# Install necessary AUR packages
yay -S ttf-ms-fonts zorin-desktop-themes zorin-icon-themes mint-themes

# Setup terminal
sudo pacman -R xterm
sudo pacman -S alacritty

# Setup pcmanfm
sudo pacman -S pcmanfm file-roller gvfs gvfs-smb gvfs-mtp
