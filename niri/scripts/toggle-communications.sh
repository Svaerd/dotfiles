#!/bin/bash

# Get the current workspace name
CURRENT=$(niri msg -j focused-workspace | jq -r '.name')

if [ "$CURRENT" = "communications" ]; then
	# Go back to the previous workspace (down)
	niri msg action focus-workspace-down
else
	# Go to communications workspace
	niri msg action focus-workspace "communications"
fi
