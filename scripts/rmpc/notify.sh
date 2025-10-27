#!/usr/bin/env sh

# Directory where to store temporary data
TMP_DIR="/tmp/rmpc"

# Ensure the directory is created
mkdir -p "$TMP_DIR"

# Generate a unique filename for each notification
ALBUM_ART_PATH="$TMP_DIR/notification_cover"

# Path to fallback album art if no album art is found by rmpc/mpd
# Change this to your needs
DEFAULT_ALBUM_ART_PATH="$TMP_DIR/default_album_art.jpg"

# Save album art of the currently playing song to a file
if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
  # Use default album art if rmpc returns non-zero exit code
  ALBUM_ART_PATH="${DEFAULT_ALBUM_ART_PATH}"
fi

# Send the notification using dunstify with a tag
notify-send -i "${ALBUM_ART_PATH}" \
  -h string:x-dunst-stack-tag:now-playing \
  "Now Playing" "$ARTIST - $TITLE"
