#!/usr/bin/env bash

# Get current workspace info
curr_workspace="$(hyprctl activeworkspace -j | jq -r ".id")"
dispatcher="$1"
target="$2"

# Help and validation
if [[ -z "${dispatcher}" || "${dispatcher}" == "--help" || "${dispatcher}" == "-h" || -z "${target}" ]]; then
  exit 1
fi

# Handle relative workspace changes (e.g., +1, -1, r+1, r-1)
if [[ "${target}" == *"+"* || "${target}" == *"-"* ]]; then
  hyprctl dispatch "${dispatcher}" "${target}"
  exit 0
fi

# Handle numeric targets (workspace groups)
if [[ "${target}" =~ ^[0-9]+$ ]]; then
  # Calculate target workspace within current group (groups of 10)
  target_workspace=$(((($curr_workspace - 1) / 10 ) * 10 + $target))
  
  # Check if we're trying to switch to workspace and already on that workspace
  if [ "${dispatcher}" = "workspace" ] && [ "$curr_workspace" = "$target_workspace" ]; then
    # If already on target workspace, go to previous workspace
    hyprctl dispatch workspace previous
  else
    # Otherwise, dispatch to the calculated target workspace
    hyprctl dispatch "${dispatcher}" "${target_workspace}"
  fi
else
  # Handle string targets (e.g., special workspaces)
  hyprctl dispatch "${dispatcher}" "${target}"
fi
