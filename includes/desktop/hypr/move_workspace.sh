#!/bin/bash

# 1. Get current workspace info
active_json=$(hyprctl activeworkspace -j)
current_name=$(echo "$active_json" | jq -r .name)
current_mon=$(echo "$active_json" | jq -r .monitorID)

# 2. Get all workspaces, filter by monitor ID, and sort by name
mapfile -t workspaces < <(hyprctl workspaces -j | \
    jq -r ".[] | select(.monitorID == $current_mon) | .name" | sort)

# 3. Find the index of the current workspace in the sorted list
for i in "${!workspaces[@]}"; do
   if [[ "${workspaces[$i]}" == "${current_name}" ]]; then
       index=$i
       break
   fi
done

total=${#workspaces[@]}

if [[ -z "$index" ]]; then
  echo "exiting! index is '$index'"
  exit 1
fi

# 4. Calculate next/prev indices with wrapping (looping)
if [[ "$1" == "next" ]]; then
    next_index=$(( (index + 1) % total ))
elif [[ "$1" == "prev" ]]; then
    next_index=$(( (index - 1 + total) % total ))
fi

# 5. Dispatch the command
hyprctl dispatch workspace "name:${workspaces[$next_index]}"
