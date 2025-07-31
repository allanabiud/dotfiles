#!/bin/bash

player_status=$(rmpc status | jq -r '.state')

if [[ "$player_status" == "Play" ]]; then
  status=''
elif [[ "$player_status" == "Pause" ]]; then
  status=''
else
  echo ""
  exit 0
fi

song_metadata=$(rmpc song | jq -r '{title: .metadata.title, albumartist: .metadata.albumartist}')

title=$(echo "$song_metadata" | jq -r '.title')
albumartist=$(echo "$song_metadata" | jq -r '.albumartist')

if [[ -z "$title" ]]; then
  title="Unknown Title"
fi

if [[ -z "$albumartist" ]]; then
  albumartist="Unknown Album Artist"
fi

song_info="$status $title - $albumartist"

echo "$song_info"
