#!/bin/bash
current=$(hyprctl getoption input:touchpad:tap-to-click 2>/dev/null)

if echo "$current" | grep -q "int: 1"; then
  hyprctl keyword "input:touchpad:tap-to-click" false
  notify-send "Touchpad" "Tap-to-click: OFF"
else
  hyprctl keyword "input:touchpad:tap-to-click" true
  notify-send "Touchpad" "Tap-to-click: ON"
fi
