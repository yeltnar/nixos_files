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
  action="movetoworkspacesilent"
else
  prompt="switch"
  action="workspace"
fi

smart_workspaces=$(
  smart_workspaces_arr=("fisms" "element" "slack" "doom" "ff")
  IFS=$'\n'
  echo "${smart_workspaces_arr[*]}"
  unset IFS
)

workspace_list=$(hyprctl workspaces | gawk 'match($0,/^[a-z].*\((.*)\)/,a){print a[1]}')
workspace_list="$workspace_list\n$smart_workspaces"
workspace_list=$(echo -e "$workspace_list" | sort -g | uniq)
workspace_number=$( echo -e "$workspace_list" | dfuzzel --dmenu --prompt "$prompt: " )

if [[ ! -n "$workspace_number" ]]; then
  # Check if the user entered a number and didn't cancel (wofi returns an empty string on cancel)
  echo 'no workspace provided'
elif [[ ! "$workspace_number" =~ ^[0-9]+$ ]]; then
  # if not match number regrex
  workspace_number="name:$workspace_number"
fi

if [[ "movetoworkspacesilent" = "$action" ]]; then
  hyprctl dispatch "$action" "$workspace_number"
fi

hyprctl dispatch workspace "$workspace_number"

