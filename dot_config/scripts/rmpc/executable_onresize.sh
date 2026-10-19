#!/usr/bin/env sh

DOTFILES="$HOME/dotfiles/stow/rmpc/.config/rmpc"
DEFAULT_CFG="$DOTFILES/config.ron"
COMPACT_CFG="$DOTFILES/config-compact.ron"
DEFAULT_THEME="$DOTFILES/themes/default.ron"
COMPACT_THEME="$DOTFILES/themes/compact.ron"

if [[ $COLS -gt 100 ]]; then
    rmpc remote --pid "$PID" set config "$DEFAULT_CFG"
    rmpc remote --pid "$PID" set theme "$DEFAULT_THEME"
    rmpc remote --pid "$PID" status "Default layout and theme set"
else
    rmpc remote --pid "$PID" set config "$COMPACT_CFG"
    rmpc remote --pid "$PID" set theme "$COMPACT_THEME"
    rmpc remote --pid "$PID" status "Compact layout and theme set"
fi
