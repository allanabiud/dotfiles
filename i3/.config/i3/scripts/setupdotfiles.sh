#!/bin/bash
# shellcheck disable=2207,2010

# This script is for setting up my dotfiles

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

# Function to install script dependencies
script_dependencies() {
	local dependencies=("stow" "git")
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
			if ! pacman -Qi "$dependency" &>/dev/null; then
				to_install+=("$dependency")
			fi
		done

		if [ ${#to_install[@]} -eq 0 ]; then
			print_success "All script dependencies are already installed"
			retry=false
		else
			print_message "The following script dependencies are missing and need to be installed:"
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

# Function to clone my dotfiles repo
clone_dotfiles() {
	local repo_url="https://github.com/abiud254/dotfiles.git"
	local target_dir="$HOME/dotfiles"
	local clone_success=false

	print_message "Cloning $repo_url to $target_dir.."
	while [ $clone_success = false ]; do
		if [ -d "$target_dir" ]; then
			print_warning "Directory $target_dir already exists."
			echo -e "${YELLOW} 1) Delete existing repo and clone again"
			echo -e "${YELLOW} 2) Try updating the existing repo"
			echo -e "${YELLOW} 3) Use existing repo without updating"
			echo -e "${YELLOW} 4) Exit"
			echo -e -n "${BLUE} Select an option (1/2/3/4): ${NC}"
			read -r choice

			case $choice in
			1)
				if confirm "Are you sure you want to delete the existing repo?"; then
					rm -rf "$target_dir"
					print_success "Dotfiles repository deleted"
					if confirm "Do you want to clone $repo_url to $target_dir?"; then
						print_message "Cloning dotfiles repository.."
						if git clone "$repo_url" "$target_dir"; then
							print_success "Dotfiles repository cloned successfully"
							clone_success=true
						else
							print_error "Failed to clone dotfiles repository"
							if ! confirm "Do you want to retry cloning the repo?"; then
								print_warning "Dotfiles repository not cloned. Exiting.."
								exit 1
							fi
						fi
					else
						print_warning "Dotfiles repository not cloned. Exiting.."
						exit 1
					fi
				else
					print_message "Existing repo not deleted. Choose another option."
				fi
				;;
			2)
				print_message "Attempting to update existing dotfiles repository.."
				if cd "$target_dir" && git pull; then
					print_success "Dotfiles repository updated"
					clone_success=true
				else
					print_error "Failed to update dotfiles repository"
					if ! confirm "Do you want to retry updating the repo?"; then
						print_warning "Dotfiles repository not updated. Exiting.."
						exit 1
					fi
				fi
				;;
			3)
				print_message "Using existing dotfiles repository.."
				clone_success=true
				;;
			4)
				print_warning "Dotfiles repository not cloned. Exiting.."
				exit 1
				;;
			*)
				print_error "Invalid option. Please select an option from the list."
				;;
			esac
		else
			if confirm "Do you want to clone $repo_url to $target_dir?"; then
				print_message "Cloning dotfiles repository.."
				if git clone "$repo_url" "$target_dir"; then
					print_success "Dotfiles repository cloned successfully"
					clone_success=true
				else
					print_error "Failed to clone dotfiles repository"
					if ! confirm "Do you want to retry cloning the repo?"; then
						print_warning "Dotfiles repository not cloned. Exiting.."
						exit 1
					fi
				fi
			else
				print_warning "Dotfiles repository not cloned. Exiting.."
				exit 1
			fi
		fi
	done
}

# Function to handle existing config files
handle_existing_dotfiles() {
	local file=$1

	if [ -e "$HOME/.config/$file" ]; then
		while true; do
			print_warning "File $HOME/.config/$file already exists."
			echo -e "${YELLOW} 1) Overwrite"
			echo -e "${YELLOW} 2) Backup and replace"
			echo -e "${YELLOW} 3) Skip this file"
			echo -e -n "${BLUE} Select an option (1/2/3): ${NC}"
			read -r choice
			case $choice in
			1)
				rm -rf "$HOME/.config/$file"
				;;
			2)
				mv "$HOME/.config/$file" "$HOME/.config/$file.backup"
				print_success "Existing file backed up as ${file}.backup"
				;;
			3)
				return 1
				;;
			*)
				print_error "Invalid option. Please select an option from the list."
				continue
				;;
			esac
			break
		done
	fi
	return 0
}

# Function to stow a specific dotfile
stow_dotfiles() {
	local dotfiles_dir="$HOME/dotfiles"
	local dotfiles_list=()

	# List all dotfiles in cloned repo
	print_message "Checking for dotfiles in cloned repo:"
	print_message "Dotfiles in cloned repo:"
	dotfiles_list=($(ls -1 "$dotfiles_dir" | grep -v -E '\.(md|git)$'))
	for ((i = 0; i < ${#dotfiles_list[@]}; i++)); do
		echo -e "${YELLOW} $((i + 1))) ${dotfiles_list[$i]}${NC}"
	done

	# Prompt user to select dotfiles to stow
	echo -e -n "\n${BLUE} Select dotfile(s) to stow (space-separated numbers, or 'a' for all): ${NC}"
	read -r selection

	# Get stow selection
	local selected_dotfiles=()
	if [ "$selection" = "a" ]; then
		selected_dotfiles=("${dotfiles_list[@]}")
	else
		for num in $selection; do
			if ((num >= 1 && num <= ${#dotfiles_list[@]})); then
				selected_dotfiles+=("${dotfiles_list[$((num - 1))]}")
			else
				print_error "Invalid selection: $num"
				return 1
			fi
		done
	fi

	# List and confirm stow selection
	echo -e "\n${BLUE}You have selected the following dotfiles to stow:${NC}"
	for ((i = 0; i < ${#selected_dotfiles[@]}; i++)); do
		echo -e "${YELLOW} - ${selected_dotfiles[$i]}${NC}"
	done
	if confirm "Is this correct?"; then
		print_message "Stowing selected dotfiles.."
	else
		print_message "Please reselect dotfiles to stow"
		stow_dotfiles
		return 1
	fi

	# Navigate to cloned repo to avoid stow slash errors
	cd "$dotfiles_dir" || {
		print_error "Failed to navigate to $dotfiles_dir"
		exit 1
	}

	# Stow selected dotfiles
	if [ "$selection" = "a" ]; then
		for dotfile in "${dotfiles_list[@]}"; do
			print_message "Stowing $dotfile"
			if handle_existing_dotfiles "$dotfile"; then
				if stow "$dotfile" -v -R -t "$HOME"; then
					print_success "Stowed $dotfile successfully"
				else
					print_error "Failed to stow $dotfile"
				fi
			else
				print_message "Skipping $dotfile"
			fi
		done
	else
		for num in $selection; do
			if ((num >= 1 && num <= ${#dotfiles_list[@]})); then
				dotfile=${dotfiles_list[$((num - 1))]}
				print_message "Stowing $dotfile"
				if handle_existing_dotfiles "$dotfile"; then
					if stow "$dotfile" -v -R -t "$HOME"; then
						print_success "Stowed $dotfile successfully"
					else
						print_error "Failed to stow $dotfile"
					fi
				else
					print_message "Skipping $dotfile"
				fi
			else
				print_error "Invalid selection: $num"
			fi
		done
	fi
}

################################################################################
## MAIN SCRIPT
################################################################################

repeat_script=true
while $repeat_script; do
	clear -x
	# PRINT WELCOME MESSAGE
	echo -e "\n${BLUE}===============================================================================${NC}"
	echo -e "${BLUE}                       DOTFILES SETUP SCRIPT ${NC}"
	echo -e "${BLUE}===============================================================================${NC}"

	echo -e "${BLUE} This is my dotfiles setup script."
	echo -e "${BLUE} It is able to:"
	echo -e "${YELLOW} - Install missing script dependencies"
	echo -e "${YELLOW} - Clone my dotfiles repository"
	echo -e "${YELLOW} - Update an existing dotfiles repository"
	echo -e "${YELLOW} - Delete an existing dotfiles repository"
	echo -e "${YELLOW} - Stow my dotfiles"
	echo -e "${YELLOW} - Overwrite existing dotfiles in .config directory"
	echo -e "${YELLOW} - Backup existing dotfiles in .config directory"
	echo -e "${YELLOW} - Repeat any section of the script you choose"
	echo -e "\n${BLUE} It is super-interactive and will ask you for confirmation before doing anything."
	echo -e "\n${BLUE} ENJOY SETTING UP YOUR DOTFILES"

	# Continue with script
	continue_with_script

	clear -x
	echo -e "\n${BLUE}========================================${NC}"
	echo -e "${BLUE}        Grant Root Access ${NC}"
	echo -e "${BLUE}========================================${NC}"
	# Call the prompt_sudo function
	prompt_sudo

	# Continue with script
	continue_with_script

	clear -x
	echo -e "\n${BLUE}========================================${NC}"
	echo -e "${BLUE}        Script Dependencies ${NC}"
	echo -e "${BLUE}========================================${NC}"
	# Install script dependencies
	script_dependencies

	# Continue with script
	continue_with_script

	clear -x
	echo -e "\n${BLUE}========================================${NC}"
	echo -e "${BLUE}  Section 1: Clone Dotfiles Repository ${NC}"
	echo -e "${BLUE}========================================${NC}"
	# Clone or update dotfiles repo
	clone_dotfiles

	# Continue with script
	continue_with_script

	clear -x
	echo -e "\n${BLUE}========================================${NC}"
	echo -e "${BLUE}  Section 2: Stow Dotfiles ${NC}"
	echo -e "${BLUE}========================================${NC}"
	# Stow dotfiles
	stow_dotfiles

	# Continue with script
	continue_with_script

	clear -x
	repeat_section=true
	while $repeat_section; do

		# Check if we need to clear the screen
		if [ "$clear_screen" = true ]; then
			clear -x
		fi

		clear_screen=true
		# SCRIPT COMPLETED
		echo -e "\n${BLUE}================================================================================${NC}"
		echo -e "${BLUE}                  DOTFILES SETUP SCRIPT COMPLETED   ${NC}"
		echo -e "${BLUE}================================================================================${NC}"

		# Prompt user if they want to repeat a section or the entire script
		echo -e "${BLUE} Would you like to:"
		echo -e "${YELLOW} 1) Repeat the entire script."
		echo -e "${YELLOW} 2) Repeat cloning the dotfiles repository (Section 1)"
		echo -e "${YELLOW} 3) Repeat stowing dotfiles (Section 2)"
		echo -e "${YELLOW} 4) Exit"
		echo -e -n "${BLUE} Select an option (1/2/3/4): ${NC}"
		read -r final_choice

		case $final_choice in
		1)
			print_message "Repeating entire script....."
			repeat_section=false
			clear_screen=true
			;;
		2)
			clear -x
			print_message "Repeating cloning dotfiles repository section....."
			echo -e "\n${BLUE}========================================${NC}"
			echo -e "${BLUE}  Section 1: Clone Dotfiles Repository ${NC}"
			echo -e "${BLUE}========================================${NC}"
			clone_dotfiles
			continue_with_script
			clear_screen=true
			;;
		3)
			clear -x
			print_message "Repeating stowing dotfiles section....."
			echo -e "\n${BLUE}========================================${NC}"
			echo -e "${BLUE}  Section 2: Stow Dotfiles ${NC}"
			echo -e "${BLUE}========================================${NC}"
			stow_dotfiles
			continue_with_script
			clear_screen=true
			;;
		4)
			print_message "Exiting script....."
			repeat_script=false
			repeat_section=false
			clear_screen=false
			;;
		*)
			print_error "Invalid option. Please select an option from the list."
			clear_screen=false
			;;
		esac
	done
done
