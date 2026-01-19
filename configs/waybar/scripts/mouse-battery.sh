#!/usr/bin/env bash

MIN_BATTERY_LEVEL=30
ERROR_ICON="⚠️"
DEVICE_ICON=""

DEVICE_PATH=$(upower --enumerate | grep -E "battery_hidpp_battery_[0-9]+$" | head -n 1)

if [[ -z "$DEVICE_PATH" ]]; then
    echo "${ERROR_ICON} No device"
    exit 0
fi

BATTERY_INFO=$(upower -i "$DEVICE_PATH" 2>/dev/null)

if [[ -z "$BATTERY_INFO" ]]; then
    echo "${ERROR_ICON} No info"
    exit 0
fi

BATTERY_LEVEL=$(echo "$BATTERY_INFO" | awk '/percentage:/ {print $2}' | tr -d '%')

if ! [[ "$BATTERY_LEVEL" =~ ^[0-9]+$ ]]; then
    echo "${ERROR_ICON} Fail extract battery level"
    exit 0
fi

if [[ "$BATTERY_LEVEL" -le $MIN_BATTERY_LEVEL ]]; then
    echo "${DEVICE_ICON} ${BATTERY_LEVEL}%"
else
    echo ""
fi
