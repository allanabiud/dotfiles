# Dotfiles

- This repository contains my dotfiles. Use them as a reference for your own setup.

## Installation

Clone this repository to your home directory:

```bash
git clone https://github.com/allanabiud/dotfiles.git ~/dotfiles
```

## Usage

All stow-managed packages are inside the `stow/` directory. For example:

- `stow/nvim/.config/nvim/`

Use GNU Stow to symlink the dotfiles. For example:

```bash
cd stow
stow -t ~ nvim zsh hyprland
```
