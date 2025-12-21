### DEFAULT TERMINAL AND EDITOR
export TERMINAL="/usr/sbin/kitty"
export TERMCMD="kitty"
export EDITOR="/usr/bin/nvim"

### XDG VARIABLES
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export XDG_PICTURES_DIR=$HOME/Pictures
#export XDG_RUNTIME_DIR=$HOME/.var/run

### ZSH VARIABLES
export HISTFILE="$XDG_CONFIG_HOME"/zsh

### GENERAL VARIABLES
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export WINEPREFIX="$XDG_DATA_HOME"/wine
export W3M_DIR="$XDG_DATA_HOME"/w3m
export XCURSOR_PATH=/usr/share/icons:$XDG_DATA_HOME/icons
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle

## NPM VARIABLES
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm

## GO
export GOPATH="$XDG_DATA_HOME"/go

## JAVA_HOME
export JAVA_HOME="/usr/lib/jvm/default/"

## ANDROID TOOLS
export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
export ANDROID_HOME="$HOME/DEV/Tools/Android-Tools/"
export FLUTTER_HOME="$HOME/DEV/Tools/flutter/bin"

### PATH VARIABLES
# Combined Path
path=(
  "$HOME/.local/bin"
  "$HOME/.local/share/cargo/bin"
  "$JAVA_HOME/bin"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$FLUTTER_HOME/bin"
  $path
)
export PATH

### PIPENV
export PIPENV_SHELL_FANCY=1
