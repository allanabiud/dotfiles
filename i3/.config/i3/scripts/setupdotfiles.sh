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
		echo -e -n "${YELLOW}$1 ([y]/n) ${NC}"
		read -r choice
		case $choice in
		y | Y) return 0 ;;
		n | N) return 1 ;;
		*) echo "Please answer y or n." ;;
		esac
	done
}

# Function to clone my dotfiles repo
clone_dotfiles() {
	local repo_url="https://github.com/abiud254/dotfiles.git"
	local target_dir="$HOME/dotfiles"
	local clone_success=false

	while [ $clone_success = false ]; do
		if [ -d "$target_dir" ]; then
			print_warning "Directory $target_dir already exists."
			echo -e "${YELLOW}1) Delete existing repo and clone again"
			echo -e "${YELLOW}2) Try updating the existing repo"
			echo -e "${YELLOW}3) Use existing repo without updating"
			echo -e "${YELLOW}4) Exit"
			echo -e -n "${YELLOW}Select an option (1/2/3/4): ${NC}"
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
					print_warning "Existing repo not deleted. Choose another option."
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
				print_error "Invalid option. Try again."
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
		print_warning "File $HOME/$file already exists."
		echo -e "${YELLOW}1) Overwrite"
		echo -e "${YELLOW}2) Backup and replace"
		echo -e "${YELLOW}3) Skip this file"
		echo -e -n "${YELLOW}Select an option (1/2/3): ${NC}"
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
			print_error "Invalid option. Skipping this file."
			return 1
			;;
		esac
	fi
	return 0
}

# Function to stow a specific dotfile
stow_dotfiles() {
	local dotfiles_dir="$HOME/dotfiles"
	local dotfiles_list=()

	# List all dotfiles in cloned repo
	print_message "Dotfiles in cloned repo:"
	dotfiles_list=($(ls -1 "$dotfiles_dir" | grep -v -E '\.(md|git)$'))
	for ((i = 0; i < ${#dotfiles_list[@]}; i++)); do
		echo -e "${YELLOW}$((i + 1))) ${dotfiles_list[$i]}${NC}"
	done

	# Stow all dotfiles
	# for dotfile in "${dotfiles_list[@]}"; do
	#   if handle_existing_dotfiles "$dotfile"; then
	#     if stow -v -R -t $HOME; then
	#       print_success "Stowed $dotfile successfully"
	#     else
	#       print_error

	# Prompt user to select dotfiles to stow
	echo -e -n "\n${BLUE}Select dotfile(s) to stow (space-separated numbers, or 'a' for all):${NC}"
	read -r selection

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
				print_warning "Skipping $dotfile"
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
					print_warning "Skipping $dotfile"
				fi
			else
				print_error "Invalid selection: $num"
			fi
		done
	fi
}

# PRINT WELCOME MESSAGE
echo -e "\n${BLUE}===============================================================================${NC}"
echo -e "${BLUE}                       DOTFILES SETUP SCRIPT ${NC}"
echo -e "${BLUE}===============================================================================${NC}"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  Section 1: Clone Dotfiles Repository ${NC}"
echo -e "${BLUE}========================================${NC}"
# Clone or update dotfiles repo
clone_dotfiles

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  Section 2: Stow Dotfiles ${NC}"
echo -e "${BLUE}========================================${NC}"
# Stow dotfiles
stow_dotfiles
