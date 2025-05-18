#!/bin/bash

# Set your mod profile and game path
PROFILE_PATH="$HOME/.config/r2modmanPlus-local/HadesII/profiles/Default"
GAME_PATH="$HOME/GAMES/INSTALLED/Hades II"

# Go to the profile directory
cd "$PROFILE_PATH" || exit 1

# Symlink all files/folders into the game directory
for f in * .*; do
  if [[ "$f" != "." && "$f" != ".." ]]; then
    ln -sfn "$PROFILE_PATH/$f" "$GAME_PATH/$f"
  fi
done

echo "Symlinks created in $GAME_PATH"
