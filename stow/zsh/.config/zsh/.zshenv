### DEFAULT TERMINAL AND EDITOR
export TERMINAL="/sbin/ghostty"
export TERMCMD="ghostty"
export EDITOR="/usr/bin/nvim"

### XDG VARIABLES
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export XDG_PICTURES_DIR=$HOME/Pictures
#export XDG_RUNTIME_DIR=$HOME/.var/run
# export XDG_SESSION_TYPE=X11
# export XDG_CURRENT_DESKTOP=sway


### EXPORT OTHER VARIABLES
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/"gtk-2.0"/gtkrc
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export WINEPREFIX="$XDG_DATA_HOME"/wine
export W3M_DIR="$XDG_DATA_HOME"/w3m
export RENPY_PATH_TO_SAVES="$XDG_DATA_HOME"
export XCURSOR_PATH=/usr/share/icons:$XDG_DATA_HOME/icons
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
# export XAUTHORITY="$XDG_RUNTIME_DIR"/Xauthority

### asdf
# export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# python
# export ASDF_PYTHON_DEFAULT_PACKAGES_FILE="$HOME/.asdf"
# export ASDF_PYTHON_VERSION="system"

### NPM VARIABLES
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm

### JAVA_HOME
export JAVA_HOME="/usr/lib/jvm/java-23-openjdk/"

### GO
export GOPATH="$XDG_DATA_HOME"/go

### FLUTTER PATH VARIABLES
export ANDROID_HOME="$HOME/DEV/Tools/android-sdk/"
export PATH=$PATH:"$HOME/DEV/Tools/flutter/bin/" # flutter-sdk
export PATH=$PATH:"$ANDROID_HOME/cmdline-tools/latest/bin" # cmdline-tools
export PATH=$PATH:"$ANDROID_HOME/platform-tools" # platform-tools

### PATH VARIABLES
export PATH=$PATH:"$HOME/.local/bin"
export PATH=$PATH:"$HOME/.local/share/cargo/bin/"
export PATH=$PATH:"$JAVA_HOME/bin"
# export PATH=$PATH:"/usr/share/sway-contrib/"

### EXPORT ALIAS VARIABLES
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias adb='HOME="$XDG_DATA_HOME"/android adb'
# alias mysql-workbench="mysql-workbench --configdir=$XDG_DATA_HOME/mysql/workbench"

### PIPENV
export PIPENV_SHELL_FANCY=1
