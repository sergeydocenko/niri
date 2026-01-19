#!/usr/bin/env bash

if [ "$1" == "check" ]; then
    if pgrep -x "gammastep" > /dev/null; then
        echo '{"text": "", "class": "active"}'  # Icon when active
    else
        echo '{"text": "", "class": "inactive"}'  # Icon when inactive
    fi
fi

if [ "$1" == "toggle" ]; then
    if pgrep -x "gammastep" > /dev/null; then
        pkill gammastep
        notify-send "Gammastep disabled" --expire-time 2000
    else
        gammastep -O 5000 &
        notify-send "Gammastep 4600K" --expire-time 2000
    fi
fi