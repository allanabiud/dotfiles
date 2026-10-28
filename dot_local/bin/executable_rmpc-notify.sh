#!/usr/bin/env sh

# "Now playing" notifications for rmpc, sent to DMS.
#
# rmpc runs this on every song change (config.ron: on_song_change) with
# $ARTIST and $TITLE in the environment. One piece of state survives
# between runs: whether the previous banner is still on screen. If it
# is, swap its content in place; if not, pop a fresh one.
#
# DMS emits no NotificationClosed signal, so "still on screen" is
# approximated by time: banners live for BANNER_MS, so a banner younger
# than that is still up. (Replacing an already-closed notification
# would be a silent "ghost" that never shows, hence the window check.)

BANNER_MS=5000
BANNER_S=$((BANNER_MS / 1000))
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/rmpc-notify"
STATE_FILE="$RUNTIME_DIR/state" # "<notification id> <epoch of last pop>"

mkdir -p "$RUNTIME_DIR"
# Drop covers left over from earlier runs; a banner still on screen may
# reference recent ones.
find "$RUNTIME_DIR" -name 'cover_*.jpg' -mmin +5 -delete 2>/dev/null

# Album art for the banner, downscaled: DMS converts images on its UI
# thread and a full-size cover made song changes stutter. A fresh file
# name per run: quickshell only re-reads an icon when its path changes.
ART_TAG="$(date +%s%N)"
ART_ICON="" # empty: no -i flag, the mpd app icon covers the icon slot
if rmpc albumart --output "$RUNTIME_DIR/cover_$ART_TAG.jpg" 2>/dev/null; then
  ART_ICON="$RUNTIME_DIR/cover_$ART_TAG.jpg"
  if ffmpeg -loglevel error -nostdin -y -i "$ART_ICON" \
    -vf "scale=w=256:h=256:force_original_aspect_ratio=decrease" \
    -q:v 6 "$RUNTIME_DIR/thumb_$ART_TAG.jpg" 2>/dev/null \
    && [ -s "$RUNTIME_DIR/thumb_$ART_TAG.jpg" ]; then
    ART_ICON="$RUNTIME_DIR/thumb_$ART_TAG.jpg"
  fi
fi

BODY="${ARTIST:-Unknown artist} - ${TITLE:-Unknown title}"

# Send the banner with the given extra flags (-r <id> updates in place,
# -p returns the new id). Album art rides the image slot: with -n set,
# -i becomes the image-path hint (the big display image), while -n mpd
# fills the small icon slot. -i is only sent when art actually exists.
send() {
  if [ -f "$ART_ICON" ]; then
    dms notify "$@" -e -t "$BANNER_MS" -n mpd -i "$ART_ICON" -a rmpc "Now Playing" "$BODY"
  else
    dms notify "$@" -e -t "$BANNER_MS" -n mpd -a rmpc "Now Playing" "$BODY"
  fi
}

# Previous banner's id and when it was popped (garbage-safe defaults).
old_id="" popped_at=0
read -r old_id popped_at 2>/dev/null <"$STATE_FILE"
case "$old_id" in '' | *[!0-9]*) old_id="" ;; esac
case "$popped_at" in '' | *[!0-9]*) popped_at=0 ;; esac

if [ -n "$old_id" ] && [ $(( $(date +%s) - popped_at )) -lt $BANNER_S ]; then
  # Banner still on screen: update it in place, same notification id.
  send -r "$old_id" >/dev/null
else
  # Nothing on screen: pop a fresh banner and remember its id.
  id=$(send -p) &&
    printf '%s %s\n' "$id" "$(date +%s)" >"$STATE_FILE.tmp" &&
    mv "$STATE_FILE.tmp" "$STATE_FILE"
fi
