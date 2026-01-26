#!/bin/bash

URGENT_ID=$(niri msg --json windows | jq -r '.[] | select(.is_urgent == true) | .id' | head -n 1)

if [ -n "$URGENT_ID" ]; then
    niri msg action focus-window --id "$URGENT_ID"
fi
