#!/usr/bin/env bash

# TODO: Get this from args
ID="qwe"
COMMAND="mc"

# Vars
TERMCMD="kitty"
CLASSNAME="SCRATCHPAD_${ID}"


# if [[ -z $(niri msg windows | grep "App ID: \"${SPID}\"") ]]
# then
#     $TERMCMD --class "$CLASSNAME" "$SPCMD"&
# else
# 	niri msg action focus-window --id "$CLASSNAME"
# 	niri msg action close-window
# fi
# else
#     if [[ -z $(niri msg -j windows | jq '.[] | select(.is_focused==true).app_id' | rg "$app") ]];
# 	then
# 	  niri msg action focus-window --id $(niri msg -j windows | jq ".[] | select(.app_id==\"$app\").id");
# 	else
# 	    niri msg action close-window;
#     fi
