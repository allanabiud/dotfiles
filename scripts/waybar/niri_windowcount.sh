#!/bin/sh

idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"
printf "%d\n" "$num"

niri msg event-stream |
  while read -r line; do
    case "$line" in
    "Window opened"* | "Window closed"* | "Workspace focused"*)
      idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
      num="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $idfocused)] | length")"
      printf "%d\n" "$num"
      ;;
    esac
  done
