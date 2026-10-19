#!/usr/bin/env sh

RMPC_DIR="$HOME/.config/rmpc"
DEFAULT_CFG="$RMPC_DIR/config.ron"
COMPACT_CFG="$RMPC_DIR/config-compact.ron"
DEFAULT_THEME="$RMPC_DIR/themes/default.ron"
COMPACT_THEME="$RMPC_DIR/themes/compact.ron"

if [[ $COLS -gt 100 ]]; then
    rmpc remote --pid "$PID" set config "$DEFAULT_CFG"
    rmpc remote --pid "$PID" set theme "$DEFAULT_THEME"
    rmpc remote --pid "$PID" status "Default layout and theme set"
else
    rmpc remote --pid "$PID" set config "$COMPACT_CFG"
    rmpc remote --pid "$PID" set theme "$COMPACT_THEME"
    rmpc remote --pid "$PID" status "Compact layout and theme set"
fi
