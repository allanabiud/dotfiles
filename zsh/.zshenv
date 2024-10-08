### ---- ZSH HOME -----------------------------------
export ZDOTDIR=$HOME/.config/zsh

### XDG VARIABLES
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export XDG_RUNTIME_DIR=$HOME/.var/run

### EXPORT OTHER VARIABLES
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/"gtk-2.0"/gtkrc
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export WINEPREFIX="$XDG_DATA_HOME"/wine
export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority
# export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

### JAVA_HOME
export JAVA_HOME="/usr/lib/jvm/java-22-openjdk"

### FLUTTER PATH VARIABLES
# export ANDROID_HOME="$HOME/DEV/FLUTTER/SDK"
# export PATH=$PATH:"$ANDROID_HOME/flutter/bin" # flutter-sdk
# export PATH=$PATH:"$ANDROID_HOME/cmdline-tools/latest/bin" # cmdline-tools
# export PATH=$PATH:"$ANDROID_HOME/platform-tools" # platform-tools

### EXPORT ALIAS VARIABLES
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias adb='HOME="$XDG_DATA_HOME"/android adb'
# alias mysql-workbench="mysql-workbench --configdir=$XDG_DATA_HOME/mysql/workbench"

### SET DEFAULT TERMINAL
export TERMINAL=/usr/bin/alacritty

### SET DEFAULT EDITOR
export EDITOR=/usr/bin/nvim

#########################
#### PATH VARIABLES
#########################
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:"$JAVA_HOME/bin"

