#!/usr/bin/env sh

# rmpc song-change notification for DMS.
#
# Strategy: keep ONE notification alive. While its banner is still on screen,
# a song change switches that notification's content in place (-r). Only once
# the banner has closed does a fresh banner pop.
#
# DMS emits no NotificationClosed signal when a banner expires, so a detached
# watcher process runs "dms notify --wait" (its timer matches the banner
# lifetime exactly: it returns after -t milliseconds) and records the state:
# while the watcher lives the banner counts as open, and when it exits it
# drops a marker file telling the next song change to pop a fresh banner.

TMP_DIR="/tmp/rmpc"
ID_FILE="$TMP_DIR/notification_id"
CLOSED_MARKER="$TMP_DIR/banner_closed"
WATCHER_PID_FILE="$TMP_DIR/watcher_pid"
BANNER_MS=6000 # banner lifetime; the watcher exits exactly after this

# Ensure the directory is created
mkdir -p "$TMP_DIR"

# --- watcher mode: spawned in the background by the normal mode below ---
# $1 = --watch, $2 = album art, $3 = artist, $4 = title
if [ "$1" = "--watch" ]; then
  echo $$ > "$WATCHER_PID_FILE"
  # -e: transient, so song changes don't pile up in DMS history
  # --id-fd 3: record the id so later runs can replace this notification
  # -w: block until the banner closes
  # -n: music icon in the icon slot; -i: album art as the larger display image
  dms notify -e -w -t "$BANNER_MS" --id-fd 3 \
    -n mpd -i "$2" -a rmpc \
    "Now Playing" "$3 - $4" 3>"$ID_FILE" >/dev/null 2>&1
  # Banner is gone now: tell the next run to pop a fresh notification.
  : > "$CLOSED_MARKER"
  exit 0
fi

# --- normal mode: called by rmpc's on_song_change hook ---

# Clean up covers left over from earlier runs. Keep recent ones: a banner
# that is still on screen may reference them.
find "$TMP_DIR" -name 'cover_*.jpg' -mmin +5 -delete 2>/dev/null

# Fetch the current song's album art (shown as the notification's image)
ALBUM_ART_PATH="$TMP_DIR/cover_$(date +%s%N).jpg"
DEFAULT_ALBUM_ART_PATH="$TMP_DIR/default_album_art.jpg"
if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
  # Use default album art if rmpc returns non-zero exit code
  ALBUM_ART_PATH="${DEFAULT_ALBUM_ART_PATH}"
fi

# Shrink the cover before handing it to DMS: it converts images on its UI
# thread, and the full-size (~1MB) image made every song change stutter.
# Unique filename per run: DMS/Quickshell only re-reads the icon when the
# path changes, so reusing one filename leaves the previous album art stuck.
if [ -f "$ALBUM_ART_PATH" ] && command -v ffmpeg >/dev/null 2>&1; then
  THUMB_PATH="$TMP_DIR/cover_thumb_$(date +%s%N).jpg"
  if ffmpeg -loglevel error -nostdin -y -i "$ALBUM_ART_PATH" \
    -vf "scale=w=256:h=256:force_original_aspect_ratio=decrease" \
    -q:v 6 "$THUMB_PATH" 2>/dev/null && [ -s "$THUMB_PATH" ]; then
    ALBUM_ART_PATH="$THUMB_PATH"
  fi
fi

# Previous notification id (only trust a plain number)
OLD_ID=""
if [ -s "$ID_FILE" ]; then
  OLD_ID=$(cat "$ID_FILE")
  case "$OLD_ID" in
    *[!0-9]*) OLD_ID="" ;;
  esac
fi

# The previous banner only counts as open while its watcher is still running
# (the cmdline check guards against pid reuse by an unrelated process).
WATCHER_OPEN=0
if [ -s "$WATCHER_PID_FILE" ]; then
  WATCHER_PID=$(cat "$WATCHER_PID_FILE")
  case "$WATCHER_PID" in
    *[!0-9]*) WATCHER_PID="" ;;
  esac
  if [ -n "$WATCHER_PID" ] \
    && kill -0 "$WATCHER_PID" 2>/dev/null \
    && grep -aq -- "--watch" "/proc/$WATCHER_PID/cmdline" 2>/dev/null; then
    WATCHER_OPEN=1
  fi
fi

if [ "$WATCHER_OPEN" -eq 1 ] && [ -n "$OLD_ID" ] && [ ! -e "$CLOSED_MARKER" ]; then
  # Banner still on screen: switch the content of the existing notification
  # instead of stacking a new one.
  dms notify -e -r "$OLD_ID" -t "$BANNER_MS" \
    -n mpd -i "$ALBUM_ART_PATH" -a rmpc \
    "Now Playing" "$ARTIST - $TITLE" >/dev/null 2>&1
else
  # Banner is gone: close any leftover object first (DMS keeps expired
  # notifications around as ghosts that never re-banner), then pop a fresh
  # notification and hand its lifetime over to a watcher.
  rm -f "$CLOSED_MARKER"
  if [ -n "$OLD_ID" ]; then
    busctl --user call org.freedesktop.Notifications /org/freedesktop/Notifications \
      org.freedesktop.Notifications CloseNotification u "$OLD_ID" >/dev/null 2>&1 || true
  fi
  rm -f "$ID_FILE"
  if command -v setsid >/dev/null 2>&1; then
    # New session: the watcher survives rmpc cleaning up its child processes.
    setsid "$0" --watch "$ALBUM_ART_PATH" "$ARTIST" "$TITLE" \
      </dev/null >/dev/null 2>&1 &
  else
    "$0" --watch "$ALBUM_ART_PATH" "$ARTIST" "$TITLE" \
      </dev/null >/dev/null 2>&1 &
  fi
  # Wait for the watcher to publish the new id, so an immediate follow-up
  # song change replaces it instead of double-bannering.
  n=0
  while [ ! -s "$ID_FILE" ] && [ "$n" -lt 25 ]; do
    sleep 0.02
    n=$((n + 1))
  done
fi
