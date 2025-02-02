####################################################################################################
### ---- autocompletions -----------------------------------
fpath=(~/.zsh/site-functions $fpath)
### asdf completions
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

### ---- Completion options and styling -----------------------------------
zstyle ':completion:*' menu select # selectable menu
#zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'  # case insensitive completion
zstyle ':completion:*' list-colors '' # colorize completion lists
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01' # colorize kill list

### zcompdump
##You must manually create the $XDG_CACHE_HOME/zsh directory if it doesn't exist yet.
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION" 

####################################################################################################
### ---- HISTORY ------------------------------------------
### -------------------------------------------------------
# History file for zsh
HISTFILE=$ZDOTDIR/.zsh_history

# How many commands to store in history
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY            # append to history file

# History Search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

####################################################################################################
### ------ ALIASES ---------------------------

# ---- switched to abbreviations ------------
alias gst="git status"
alias grep='grep --color'
# ----- eza ---------------------------------
alias ls="eza --icons --group-directories-first -l"
alias ll="eza --icons --group-directories-first -la"
# ----- neovim ---------------------------------
alias v="nvim"
# ----- keepassxc-cli -----------------------
# alias kp-search="keepassxc-cli search /home/abiudy/Documents/KeePassXC/Passwords.kdbx"
# alias kp-show="keepassxc-cli show /home/abiudy/Documents/KeePassXC/Passwords.kdbx --all"
# alias kp-clip="keepassxc-cli clip /home/abiudy/Documents/KeePassXC/Passwords.kdbx"
# alias kp-clip-a="keepassxc-cli clip /home/abiudy/Documents/KeePassXC/Passwords.kdbx -a"
# ----- obsidian.nvim -----------------------
alias notes="nvim ~/Desktop/Obsidian/"
# ----- zellij -----------------------
alias zellij="zellij -l welcome"
alias zel="zellij -l welcome"


####################################################################################################
### ----------------------------------------------------------------------------

### ---- Starship -----------------------------------
eval "$(starship init zsh)"
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

# ------ Zoxide -------------------------------------
eval "$(zoxide init --cmd cd zsh)"

### --- ZSH Syntax Highlighting ------------------------------
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

### --- ZSH AutoSuggestions ---------------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# pnpm
# export PNPM_HOME="/home/abiudy/.local/share/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# pnpm end

### --- Yazi -----------------------------------
# function y() {
# 	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
# 	yazi "$@" --cwd-file="$tmp"
# 	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
# 		builtin cd -- "$cwd"
# 	fi
# 	rm -f -- "$tmp"
# }
# source "$ZDOTDIR"/.yazi.sh

### Direnv
# eval "$(direnv hook zsh)"

### Pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init - zsh)"
