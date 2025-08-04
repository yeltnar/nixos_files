#!/bin/bash

active_workspaces=$(hyprctl workspaces | awk '/^[a-z]/{print $3}' | sort -g)

# number of workspaces
workspace_count=$(echo "$active_workspaces" | wc -l)

echo "$active_workspaces"
echo $workspace_count

# we need to add one for some reason
workspace_count=$((workspace_count+1))

prompt=""
if [[ "move" == "$@" ]]; then
  prompt="move"
  action="movetoworkspace"
else
  prompt="switch"
  action="workspace"
fi

workspace_list=$(hyprctl workspaces | awk '/^[a-z]/{print $3}' | sort -g)
workspace_list=""
workspace_number=$( echo "$workspace_list" | bemenu -n -p "$prompt" -W .5 --center --fn 32)

if [[ ! -n "$workspace_number" ]]; then
  # Check if the user entered a number and didn't cancel (wofi returns an empty string on cancel)
  echo 'no workspace provided'
elif [[ ! "$workspace_number" =~ ^[0-9]+$ ]]; then
  # if not match number regrex
  workspace_number="name:$workspace_number"
fi

hyprctl dispatch "$action" "$workspace_number"

