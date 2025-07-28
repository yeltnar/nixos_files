#!/usr/bin/env bash
pkill waybar
waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css &
