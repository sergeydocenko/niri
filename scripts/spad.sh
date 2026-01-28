#!/usr/bin/env bash

# Usage: ./spad.sh "myterm" "foot --title myterm"
PAD_NAME="$1"
APP_CMD="$2"

# 1. Find if the window already exists (matching by title or app-id)
# We check both title and app_id for flexibility
WINDOW_DATA=$(niri msg -j windows | jq -r ".[] | select(.title == \"$PAD_NAME\" or .app_id == \"$PAD_NAME\")")

if [ -z "$WINDOW_DATA" ]; then
    echo "Window doesn't exist: Spawn it"
    niri msg action spawn -- $APP_CMD
else
    WINDOW_ID=$(echo "$WINDOW_DATA" | jq -r '.id')
    IS_FOCUSED=$(echo "$WINDOW_DATA" | jq -r '.is_focused')
    if [ "$IS_FOCUSED" = "true" ]; then
        # It's visible and focused: Hide it to a special workspace
        niri msg action move-window-to-workspace "scratchpad_storage" --window-id "$WINDOW_ID"
    else
        # It's hidden: Bring it to current workspace and focus
        niri msg action move-window-to-current-workspace --window-id "$WINDOW_ID"
        niri msg action focus-window --window-id "$WINDOW_ID"
    fi
fi