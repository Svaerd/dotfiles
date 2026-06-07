#!/bin/bash
# Focuses the warp window and sends Ctrl+Shift+N to open a new tab/window

WARP_PID=$(pgrep -f "warp-terminal/warp$" | head -1)

if [ -z "$WARP_PID" ]; then
    warp-terminal &
    exit 0
fi

WARP_WIN_ID=$(niri msg windows 2>/dev/null | grep -A1 "pid $WARP_PID" | grep "^Window ID" | awk '{print $3}' | tr -d ':')

if [ -n "$WARP_WIN_ID" ]; then
    niri msg action focus-window --id "$WARP_WIN_ID"
    sleep 0.1
fi

ydotool key ctrl+shift+n