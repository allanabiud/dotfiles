#!/bin/bash
# shellcheck disable=3054,3043,3030,2206,3024,3037,3010,3045,2086,3020,2004

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
		echo -e -n "${YELLOW}$1 ([y]/n) ${GREEN}(Default: y): ${NC}"
		read -r choice
		case $choice in
		"" | y | Y) return 0 ;;
		n | N) return 1 ;;
		*) echo "Please answer Y/y, N/n or press Enter for yes." ;;
		esac
	done
}

# Function to print items in a grid layout
print_grid() {
	local items=("$@")
	local cols=4
	local rows=$(((${#items[@]} + cols - 1) / cols))
	local col_width=25 # Adjust this value to change the column width

	for ((i = 0; i < rows; i++)); do
		for ((j = 0; j < cols; j++)); do
			index=$((i + j * rows))
			if [ $index -lt ${#items[@]} ]; then
				printf "${YELLOW} - %-${col_width}s${NC}" "${items[$index]}"
			fi
		done
		echo
	done
}

# Continue with script function
continue_with_script() {
	echo -e -n "\n${BLUE}----------------------------------------${NC}"
	if confirm "Continue?"; then
		print_message "Continuing......"
	else
		print_message "Exiting......"
		echo -e "${BLUE}----------------------------------------${NC}"
		exit 1
	fi
	echo -e "${BLUE}----------------------------------------${NC}"
}

# Prompt for sudo access with confirmation
prompt_sudo() {
	print_warning "SUDO PRIVILEGES REQUIRED"
	if confirm "Do you want to grant sudo access?"; then
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
	if confirm "Do you want to run a system update?"; then
		local max_retries=3
		local retry_count=0

		while [ $retry_count -lt $max_retries ]; do
			print_message "Updating your system.."
			if sudo pacman -Syu --noconfirm; then
				print_success "System updated"
				return 0
			else
				print_error "System update failed"
				if [ $retry_count -lt $(($max_retries - 1)) ]; then
					if confirm "Do you want to retry the update?"; then
						((retry_count++))
					else
						print_message "Skipping system update"
						return 0
					fi
				else
					print_error " Maximum retries reached."
					if confirm "Do you want to skip the update?"; then
						print_message "Skipping system update.."
						return 0
					else
						print_message "Retrying system update.."
					fi
				fi
			fi
		done
	else
		print_message "Skipping system update"
	fi
}

# Function to install script dependencies
script_dependencies() {
	local dependencies=("git" "curl" "wget" "base-devel")
	local to_install=()
	local retry=true

	while $retry; do
		print_message "Script dependencies required:"
		for dependency in "${dependencies[@]}"; do
			echo -e "${YELLOW} - $dependency${NC}"
		done
		echo

		print_message "Checking if dependencies are installed...."
		for dependency in "${dependencies[@]}"; do
			if ! pacman -Qi $dependency &>/dev/null; then
				to_install+=($dependency)
			fi
		done

		if [ ${#to_install[@]} -eq 0 ]; then
			print_success "All script dependencies are already installed"
			retry=false
		else
			print_message "The following missing script dependencies need to be installed:"
			for dependency in "${to_install[@]}"; do
				echo -e "${YELLOW} - $dependency${NC}"
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
		print_message "Package required:"
		for dependency in "${dependencies[@]}"; do
			echo -e "${YELLOW} - $dependency${NC}"
		done
		echo

		print_message "Checking if $dependency is installed...."
		for dependency in "${dependencies[@]}"; do
			if ! pacman -Qi $dependency &>/dev/null; then
				to_install+=($dependency)
			fi
		done

		if [ ${#to_install[@]} -eq 0 ]; then
			print_success "yay is already installed"
			retry=false
		else
			print_message "The following package needs to be installed:"
			for dependency in "${to_install[@]}"; do
				echo -e "${YELLOW} - $dependency${NC}"
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
			echo -e "${YELLOW} - $dependency${NC}"
		done
		echo

		print_message "Checking if dependencies are installed...."
		for dependency in "${dependencies[@]}"; do
			if ! pacman -Qi $dependency &>/dev/null; then
				to_install+=($dependency)
			fi
		done

		if [ ${#to_install[@]} -eq 0 ]; then
			print_success "All i3 dependencies are already installed"
			retry=false
		else
			print_message "The following missing i3 dependencies need to be installed:"
			for dependency in "${to_install[@]}"; do
				echo -e "${YELLOW} - $dependency${NC}"
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
			echo -e "${YELLOW} - $dependency${NC}"
		done
		echo

		print_message "Checking if terminal dependencies are installed...."
		for dependency in "${dependencies[@]}"; do
			if ! pacman -Qi $dependency &>/dev/null; then
				to_install+=($dependency)
			fi
		done
		if [ ${#to_install[@]} -eq 0 ]; then
			print_success "All terminal dependencies are already installed"
			retry=false
		else
			print_message "The following missing terminal dependencies need to be installed:"
			for dependency in "${to_install[@]}"; do
				echo -e "${YELLOW} - $dependency${NC}"
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
setup_dotfiles() {
	if [ -f "./setupdotfiles.sh" ]; then
		if confirm "Do you want to run the dotfiles setup script?"; then
			print_message "Running dotfiles setup script.."
			if bash ./setupdotfiles.sh; then
				print_success "Dotfiles setup script completed successfully"
			else
				print_error "Dotfiles setup failed"
			fi
		else
			print_warning "Skipping dotfiles setup"
		fi
	else
		print_warning "Dotfiles setup script not found"
	fi
}

################################
# APPLICATION FUNCTIONS
################################
# Function to install and setup i3wm environment applications
i3wm_applications() {
	local applications=("p7zip" "unrar" "tar" "rsync" "htop" "exfat-utils" "fuse-exfat" "ntfs-3g" "flac" "jasper" "aria2" "xss-lock" "thermald" "tlp" "nitrogen" "picom" "dunst" "fastfetch" "pavucontrol" "xclip" "ttf-meslo-nerd" "ttf-font-awesome" "pcmanfm" "gvfs" "gvfs-mtp" "gvfs-smb" "file-roller" "gparted" "openssh" "vi" "vim" "nano" "bluez" "bluez-utils" "blueman" "j4-dmenu-desktop" "lxappearance" "gnome-keyring" "android-tools" "arandr" "xorg-xrandr" "flatpak" "timeshift" "intel-ucode" "jdk-openjdk" "nodejs" "npm" "rustup")
	local to_install=()
	local retry=true

	while $retry; do
		print_message "i3wm Environment Applications to be installed:"
		print_grid "${applications[@]}"
		echo

		#  BUG: This is not working correctly

		# print_message "Checking if applications are installed...."
		# for application in "${applications[@]}"; do
		# 	if ! pacman -Qi $application &>/dev/null; then
		# 		to_install+=($application)
		# 	fi
		# 	if [ ${#to_install[@]} -eq 0 ]; then
		# 		print_success "All i3wm environment applications are already installed"
		# 		retry=false
		# 	else
		# 		print_message "The following missing i3wm environment applications need to be installed:"
		# 		for dependency in "${to_install[@]}"; do
		# 			print_grid "${dependency}"
		# 		done
		# 		if confirm "Do you want to install these applications?"; then
		# 			print_message "Installing i3wm environment applications.."
		# 			if sudo pacman -S --noconfirm "${to_install[@]}"; then
		# 				print_success "i3wm environment applications installed successfully"
		# 				retry=false
		# 			else
		# 				print_error "Failed to install i3wm environment applications"
		# 				if confirm "Do you want to retry the installation?"; then
		# 					retry=true
		# 				else
		# 					if confirm "Do you want to continue without i3wm environment applications?"; then
		# 						print_message "Continuing without i3wm environment applications.."
		# 					else
		# 						print_error "Exiting.."
		# 						exit 1
		# 					fi
		# 				fi
		# 			fi
		# 		else
		# 			if confirm "Do you want to continue without i3wm environment applications?"; then
		# 				print_message "Continuing without i3wm environment applications.."
		# 			else
		# 				print_error "Exiting.."
		# 				exit 1
		# 			fi
		# 		fi
		# 	fi
		# done
	done
}
################################################################################
## MAIN SCRIPT
################################################################################

clear
# PRINT WELCOME MESSAGE
echo -e "\n${BLUE}===============================================================================${NC}"
echo -e "${BLUE}                  i3WM SETUP SCRIPT FOR ARCH LINUX ${NC}"
echo -e "${BLUE}===============================================================================${NC}"

echo -e "${BLUE} This is my i3 setup script for Arch Linux"
echo -e "${BLUE} It is meant to be run once after installation of i3 using the archinstall script"
echo -e "${BLUE} This script is able to:"
echo -e "${YELLOW} - Update the system"
echo -e "${YELLOW} - Install script and i3wm dependencies"
echo -e "${YELLOW} - Install the yay AUR Helper"
echo -e "${YELLOW} - Setup my terminal dependencies"
echo -e "${YELLOW} - Setup my dotfiles using the setupdotfiles.sh script"
echo -e "${YELLOW} - Install various applications used by i3 and pesonal applications"
echo -e "${YELLOW} - Repeat any section of the script you choose"
echo -e "\n${BLUE} It is super-interactive and will ask you for confirmation before doing anything."
echo -e "\n${BLUE} ENJOY SETTING UP YOUR I3 WM INSTANCE!!"

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 1: Grant Root Access ${NC}"
echo -e "${BLUE}========================================${NC}"
# Call the prompt_sudo function
prompt_sudo

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 2: Update System ${NC}"
echo -e "${BLUE}========================================${NC}"
# Update system
update_system

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 3: Dependencies ${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${BLUE}******************************${NC}"
echo -e "${BLUE}  Part 1: Script Dependencies ${NC}"
echo -e "${BLUE}******************************${NC}"
# Install script dependencies
script_dependencies

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}******************************${NC}"
echo -e "${BLUE}  Part 2: Install yay ${NC}"
echo -e "${BLUE}******************************${NC}"
# Install yay
yay_install

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}******************************${NC}"
echo -e "${BLUE}  Part 3: i3 Dependencies ${NC}"
echo -e "${BLUE}******************************${NC}"
# Install i3 dependencies
i3_dependencies

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 4: Terminal Setup ${NC}"
echo -e "${BLUE}========================================${NC}"
# Setup terminal
terminal_setup

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 5: Setup Dotfiles ${NC}"
echo -e "${BLUE}========================================${NC}"
# Setup dotfiles
setup_dotfiles

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}----------------------------------------${NC}"
echo -e "${BLUE}    DOTFILES SETUP SCRIPT COMPLETED      ${NC}"
echo -e "${BLUE}    CONTINUE WITH I3 SETUP SCRIPT?              ${NC}"
echo -e "${BLUE}----------------------------------------${NC}"

# Continue with script
continue_with_script

clear -x
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}   Section 6: Applications ${NC}"
echo -e "${BLUE}========================================${NC}"
# Setup i3wm environment applications
i3wm_applications

# Continue with script
continue_with_script

clear -x
# SCRIPT COMPLETED
echo -e "\n${BLUE}================================================================================${NC}"
echo -e "${BLUE}                  I3 SETUP SCRIPT COMPLETED   ${NC}"
echo -e "${BLUE}================================================================================${NC}"
