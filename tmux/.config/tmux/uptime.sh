#!/bin/sh

# Keep shell substitutions and printf formats out of tmux's status format.
sysctl -n kern.boottime | awk -v now="$(date +%s)" '{
    seconds = now - $4
    printf "%dd %02dh %02dm\n", seconds / 86400, seconds / 3600 % 24, seconds / 60 % 60
}'
