#!/usr/bin/env sh

# Directory where to store temporary data
TMP_DIR="/tmp/rmpc"

# Ensure the directory is created
mkdir -p "$TMP_DIR"

# Generate a unique filename for each notification
ALBUM_ART_PATH="$TMP_DIR/cover_$(date +%s%N).jpg"

# Path to fallback album art if no album art is found by rmpc/mpd
# Change this to your needs
DEFAULT_ALBUM_ART_PATH="$TMP_DIR/default_album_art.jpg"

# Cleanup old covers to prevent /tmp from filling up
rm -f $TMP_DIR/cover_*.jpg

# Save album art of the currently playing song to a file
if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
  # Use default album art if rmpc returns non-zero exit code
  ALBUM_ART_PATH="${DEFAULT_ALBUM_ART_PATH}"
fi

# Send the notification
notify-send -i "${ALBUM_ART_PATH}" \
  "Now Playing" "$ARTIST - $TITLE"
