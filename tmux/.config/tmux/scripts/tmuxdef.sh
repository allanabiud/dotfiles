#!/bin/bash

# This script is run when tmux is started.
# It is a default session script.

tmux new-session -d -s 'default'
tmux -2 attach-session -d
