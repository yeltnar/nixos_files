#!/usr/bin/env bash
if [[ "$RESTART" != "false" ]];
  pkill waybar
fi
waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css &
