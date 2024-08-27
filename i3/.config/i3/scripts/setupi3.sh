#!/bin/bash
# shellcheck disable=3054,3043,3030,2206,3024,3037,3010,3045,2086,3020

# This is my i3 setup script for Arch Linux
# It is meant to be run once after installation of i3 using the archinstall script
# This script will install dependencies, my dotfiles and applications I use

# COLORS
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
  echo -e "\n${BLUE}==> $1${NC}"
}
# Function to print success message
print_success() {
  echo -e "\n${GREEN}==> $1${NC}"
}
# Function to print error message
print_error() {
  echo -e "\n${RED}==> $1${NC}"
}
# Function to print warning message
print_warning() {
  echo -e "\n${YELLOW}==> $1${NC}"
}

# Prompt user for confirmation
confirm() {
  echo
  while true; do
    echo -e -n "${YELLOW}$1 ([y]/n) ${NC}"
    read -r choice
    case $choice in
    y | Y) return 0 ;;
    n | N) return 1 ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

# Prompt for sudo access with confirmation
prompt_sudo() {
  print_warning "ROOT PRIVILEGES REQUIRED"
  if confirm "This script requires sudo privileges. Do you want to grant root access?"; then
    # Clear any existing sudo credentials
    sudo -k
    # Attempt to get sudo access
    if sudo -v; then
      print_success "Root access granted"
      #Keep sudo privileges alive
      sudo -v
      while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
      done 2>/dev/null &
    else
      print_error "Failed to get sudo access. Exiting."
      exit 1
    fi
  else
    print_error "Root access denied. Exiting."
    exit 1
  fi
}

# Function to update system
update_system() {
  local retry=true

  while $retry; do
    print_message "Updating your system.."
    if sudo pacman -Syu --noconfirm; then
      print_success "System updated"
      retry=false
    else
      print_error "System update failed"
      if confirm "Do you want to retry the update?"; then
        retry=true
      else
        print_warning "Skipping system update"
        retry=false
      fi
    fi
  done
}

# Function to install script dependencies
script_dependencies() {
  local dependencies=("git" "curl" "wget" "base-devel")
  local to_install=()
  local retry=true

  while $retry; do
    print_message "Script dependencies to be installed:"
    for dependency in "${dependencies[@]}"; do
      echo -e "${YELLOW}- $dependency${NC}"
    done
    echo

    for dependency in "${dependencies[@]}"; do
      if ! pacman -Qi $dependency &>/dev/null; then
        to_install+=($dependency)
      fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
      print_success "All script dependencies are already installed"
      retry=false
    else
      print_success "The following missing script dependencies need to be installed:"
      for dependency in "${to_install[@]}"; do
        echo -e "${YELLOW}- $dependency${NC}"
      done

      if confirm "Do you want to install these dependencies?"; then
        print_message "Installing script dependencies.."
        if sudo pacman -S --noconfirm "${to_install[@]}"; then
          print_success "Script dependencies installed successfully"
          retry=false
        else
          print_error "Failed to install script dependencies"
          if confirm "Do you want to retry the installation?"; then
            retry=true
          else
            print_warning "Script dependencies are required for this script. Exiting.."
            exit 1
          fi
        fi
      else
        print_warning "Script dependencies are required for this script. Exiting."
        exit 1
      fi
    fi
  done
}

# Function to install yay
yay_install() {
  local dependencies=("yay")
  local to_install=()
  local retry=true

  while $retry; do
    print_message "Package to be installed:"
    for dependency in "${dependencies[@]}"; do
      echo -e "${YELLOW}- $dependency${NC}"
    done
    echo

    for dependency in "${dependencies[@]}"; do
      if ! pacman -Qi $dependency &>/dev/null; then
        to_install+=($dependency)
      fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
      print_success "yay is already installed"
      retry=false
    else
      print_success "The following package needs to be installed:"
      for dependency in "${to_install[@]}"; do
        echo -e "${YELLOW}- $dependency${NC}"
      done

      if confirm "Do you want to install yay?"; then
        print_message "Installing yay.."
        if git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm; then
          print_success "yay dependencies installed successfully"
          retry=false
        else
          print_error "Failed to install yay AUR Helper"
          if confirm "Do you want to retry the installation?"; then
            retry=true
          else
            print_warning "yay is required for the application part of this script."
            if confirm "Do you want to continue without yay?"; then
              print_message "Continuing without yay.."
            else
              print_error "Exiting.."
              exit 1
            fi
          fi
        fi
      else
        print_warning "yay is required for the application part of this script."
        if confirm "Do you want to continue without yay?"; then
          print_message "Continuing without yay.."
        else
          print_error "Exiting.."
          exit 1
        fi
      fi
    fi
  done
}

# Function to check and install i3 dependencies
i3_dependencies() {
  local dependencies=("i3lock" "i3status" "i3blocks" "dmenu")
  local to_install=()
  local retry=true

  while $retry; do
    print_message "i3 dependencies to be installed:"
    for dependency in "${dependencies[@]}"; do
      echo -e "${YELLOW}- $dependency${NC}"
    done
    echo

    for dependency in "${dependencies[@]}"; do
      if ! pacman -Qi $dependency &>/dev/null; then
        to_install+=($dependency)
      fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
      print_success "All i3 dependencies are already installed"
      retry=false
    else
      print_success "The following missing i3 dependencies need to be installed:"
      for dependency in "${to_install[@]}"; do
        echo -e "${YELLOW}- $dependency${NC}"
      done

      if confirm "Do you want to install these dependencies?"; then
        print_message "Installing i3 dependencies.."
        if sudo pacman -S --noconfirm "${to_install[@]}"; then
          print_success "i3 dependencies installed successfully"
          retry=false
        else
          print_error "Failed to install i3 dependencies"
          if confirm "Do you want to retry the installation?"; then
            retry=true
          else
            print_warning "i3 dependencies are required for this i3wm. Exiting."
            exit 1
          fi
        fi
      else
        print_warning "i3 dependencies are required for this i3wm. Exiting."
        exit 1
      fi
    fi
  done
}

# Function to setup terminal
terminal_setup() {
  local dependencies=("alacritty" "starship" "zsh" "zsh-autosuggestions" "zsh-syntax-highlighting")
  local to_install=()
  local retry=true

  while $retry; do
    print_message "Terminal dependencies to be installed:"
    for dependency in "${dependencies[@]}"; do
      echo -e "${YELLOW}- $dependency${NC}"
    done
    echo
    for dependency in "${dependencies[@]}"; do
      if ! pacman -Qi $dependency &>/dev/null; then
        to_install+=($dependency)
      fi
    done
    if [ ${#to_install[@]} -eq 0 ]; then
      print_success "All terminal dependencies are already installed"
      retry=false
    else
      print_success "The following missing terminal dependencies need to be installed:"
      for dependency in "${to_install[@]}"; do
        echo -e "${YELLOW}- $dependency${NC}"
      done
      if confirm "Do you want to install these dependencies?"; then
        print_message "Installing terminal dependencies.."
        if sudo pacman -S --noconfirm "${to_install[@]}"; then
          print_success "Terminal dependencies installed successfully"
          retry=false
        else
          print_error "Failed to install terminal dependencies"
          if confirm "Do you want to retry the installation?"; then
            retry=true
          else
            if confirm "Do you want to continue without terminal dependencies?"; then
              print_message "Continuing without terminal dependencies.."
            else
              print_error "Exiting.."
              exit 1
            fi
          fi
        fi
      else
        if confirm "Do you want to continue without terminal dependencies?"; then
          print_message "Continuing without terminal dependencies.."
        else
          print_error "Exiting.."
          exit 1
        fi
      fi
    fi
  done
}

# Function to setup dotfiles

# PRINT WELCOME MESSAGE
echo -e "\n${BLUE}===============================================================================${NC}"
echo -e "${BLUE}                  i3WM SETUP SCRIPT FOR ARCH LINUX ${NC}"
echo -e "${BLUE}===============================================================================${NC}"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 1: Grant Root Access ${NC}"
echo -e "${BLUE}========================================${NC}"
# Call the prompt_sudo function
prompt_sudo

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 2: Update System ${NC}"
echo -e "${BLUE}========================================${NC}"
# Update system
update_system

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 3: Dependencies ${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}******************************${NC}"
echo -e "${BLUE}  Part 1: Script Dependencies ${NC}"
echo -e "${BLUE}******************************${NC}"
# Install script dependencies
script_dependencies

echo -e "\n${BLUE}******************************${NC}"
echo -e "${BLUE}  Part 2: Install yay ${NC}"
echo -e "${BLUE}******************************${NC}"
# Install yay
yay_install

echo -e "\n${BLUE}******************************${NC}"
echo -e "${BLUE}  Part 3: i3 Dependencies ${NC}"
echo -e "${BLUE}******************************${NC}"
# Install i3 dependencies
i3_dependencies

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 4: Terminal Setup ${NC}"
echo -e "${BLUE}========================================${NC}"
# Setup terminal
terminal_setup

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 5: Dotfiles ${NC}"
echo -e "${BLUE}========================================${NC}"
# Setup dotfiles

# SCRIPT COMPLETED
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${BLUE}                       SCRIPT COMPLETED   ${NC}"
echo -e "${BLUE}================================================================================${NC}"
