#!/bin/bash
hyprctl clients -j | jq -r '.[] | select(.initialClass | contains("firefox")) | .address' | while read -r firefox_window_title; do
    hyprctl dispatch movetoworkspacesilent name:firefox,address:$firefox_window_title
done
