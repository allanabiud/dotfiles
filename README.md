# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start on a New Machine

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply allanabiud
```

Or if chezmoi is already installed:

```bash
chezmoi init --apply allanabiud/dotfiles
```

## Structure

- Active configs (`niri`, `hypr`, `kitty`, `starship`, `zsh`, `nvim`, `yazi`, `mpd`, `rmpc`, `fastfetch`, `scripts`) are applied directly.
- Inactive configs (`i3`, `sway`, `mango`, `waybar`, etc.) are safely stored in `.chezmoiignore` and can be enabled whenever needed.
- Scripts are located in `~/.config/scripts/`.
