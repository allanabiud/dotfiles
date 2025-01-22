#!/bin/bash

# Ensure rmpc and jq are available
if ! command -v rmpc &>/dev/null; then
  echo "Error: rmpc is not installed."
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed."
  exit 1
fi

case "$1" in
random)
  current_state=$(rmpc status | jq -r '.random')
  if [ "$current_state" = "true" ]; then
    rmpc random off
  else
    rmpc random on
  fi
  ;;
repeat)
  current_state=$(rmpc status | jq -r '.repeat')
  if [ "$current_state" = "true" ]; then
    rmpc repeat off
  else
    rmpc repeat on
  fi
  ;;
single)
  current_state=$(rmpc status | jq -r '.single')
  if [ "$current_state" = "On" ]; then
    rmpc single off
  else
    rmpc single on
  fi
  ;;
consume)
  current_state=$(rmpc status | jq -r '.consume')
  if [ "$current_state" = "On" ]; then
    rmpc consume off
  else
    rmpc consume on
  fi
  ;;
status)
  rmpc status
  ;;
*)
  echo "Usage: $0 {random|single|consume|status}"
  exit 1
  ;;
esac
