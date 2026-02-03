#!/usr/bin/env bash

# Script to close all windows in current niri workspace except the current one

# Get the current workspace and focused window
current_workspace=$(niri msg -j workspaces | jq -r '.[] | select(.is_active == true) | .idx')
focused_window=$(niri msg -j windows | jq -r '.[] | select(.is_focused == true) | .id')

# Check if we got valid data
if [ -z "$current_workspace" ]; then
    echo "Error: Could not determine current workspace"
    exit 1
fi

if [ -z "$focused_window" ]; then
    echo "Error: Could not determine focused window"
    exit 1
fi

echo "Current workspace: $current_workspace"
echo "Focused window ID: $focused_window"
echo "Closing other windows..."

# Get all windows in the current workspace and close them except the focused one
niri msg -j windows | jq -r --arg ws "$current_workspace" --arg focused "$focused_window" \
    '.[] | select(.workspace_id == ($ws | tonumber) and .id != ($focused | tonumber)) | .id' | \
while read -r window_id; do
    if [ -n "$window_id" ]; then
        echo "Closing window ID: $window_id"
        niri msg action close-window --id "$window_id"
    fi
done

echo "Done!"