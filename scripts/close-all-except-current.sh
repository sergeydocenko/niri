#!/usr/bin/env bash

#
# Close all windows in the CURRENT workspace
# except the currently focused window.
#
# Requires:
#   - niri
#   - jq
#
# Safe behavior:
#   - Only affects the focused workspace
#   - Never closes the focused window itself
#

set -euo pipefail

json="$(niri msg -j windows )"

# Extract all window IDs in the currently focused workspace
# except the focused window itself.
#
# jq logic:
#   .[]                                  -> iterate workspaces
#   select(.workspace.focused == true)  -> only current workspace
#   .windows[]                          -> iterate its windows
#   select(.focused == false)           -> skip focused window
#   .id                                 -> output window id
#
mapfile -t windows_to_close < <(
    jq -r '
        .[]
        | select(.workspace.focused == true)
        | .windows[]
        | select(.focused == false)
        | .id
    ' <<< "$json"
)

# If nothing to close, exit quietly
if [[ "${#windows_to_close[@]}" -eq 0 ]]; then
    exit 0
fi

# Close each window one by one
for win_id in "${windows_to_close[@]}"; do
    # You could add logging here if you want:
    # echo "Closing window $win_id"
    niri msg close-window "$win_id"
done