#!/usr/bin/env bash

pane_content=$(tmux capture-pane -p)

urls=$(echo "$pane_content" | grep -oE 'https?://[^[:space:]<>]+' | sort -u)

if [ -z "$urls" ]; then
    tmux display-message "No URLs found in current pane"
    exit 1
fi

selected_url=$(tmux display-popup -E -w 80% -h 80% "echo '$urls' | fzf --height 100% --border --prompt='Select URL: ' --bind 'alt-j:down,alt-k:up'")

if [ -n "$selected_url" ]; then
    xdg-open "$selected_url" 2>/dev/null
fi
