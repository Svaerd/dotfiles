#!/bin/bash
CONF_DIR="$HOME/.cache/dotfiles/hypr/custom"

if grep -q "tap-to-click = true" "$CONF_DIR/tap-to-click.conf"; then
    cp "$CONF_DIR/tap-off.conf" "$CONF_DIR/tap-to-click.conf"
    notify-send "Touchpad" "Tap-to-click: OFF"
else
    cp "$CONF_DIR/tap-on.conf" "$CONF_DIR/tap-to-click.conf"
    notify-send "Touchpad" "Tap-to-click: ON"
fi
hyprctl reload
