#!/usr/bin/env bash

notify-send 'Restart NetworkManager' --expire-time 2000
echo qwe | sudo -S systemctl restart NetworkManager.service

