#!/bin/bash

active_workspaces=$(hyprctl workspaces | awk '/^[a-z]/{print $3}' | sort -g)

# number of workspaces
workspace_count=$(echo "$active_workspaces" | wc -l)

echo "$active_workspaces"
echo $workspace_count

# we need to add one for some reason
workspace_count=$((workspace_count+1))

# exit

# Prompt the user for a workspace number using wofi's dmenu mode
# -d: Use dmenu mode
# -p "Prompt Text": Sets the prompt text
# empty string so there is no dropdown 

# workspace_number=$( echo "$active_workspaces" | wofi -d --lines="$workspace_count" --sort="default" -p "Go to Workspace:")

workspace_number=$(hyprctl workspaces | awk '/^[a-z]/{print $3}' | sort -g | bemenu --center -W .5 --fn 32)

# Check if the user entered a number and didn't cancel (wofi returns an empty string on cancel)
if [[ -n "$workspace_number" && "$workspace_number" =~ ^[0-9]+$ ]]; then
  # Use hyprctl to switch to the specified workspace
  hyprctl dispatch workspace "$workspace_number"
else
  # Optional: Echo a message if the input was invalid or cancelled
  echo "Invalid input or operation cancelled."
fi
