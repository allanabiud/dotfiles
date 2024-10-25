export XDG_SESSION_TYPE=X11
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3
export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share
export XDG_RUNTIME_DIR=/run/user/1000
export ZDOTDIR=~/.config/zsh

if [ -d ~/.config/i3 ]; then
    i3-msg restart
fi

xrdb -merge ~/.Xresources

exec i3
