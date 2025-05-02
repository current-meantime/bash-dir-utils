#!/bin/bash

# this script provides a simple way to select files or directories from the current directory.
# it allows you to select an item by its number and store it in a variable.
# usage: sel [item number]
# example: sel 2
# it's recommended to use this in combination with the 'lcd' utility
# which lists files and directories with line numbers.

# Load configuration
if [ -f "$HOME/.sel_config" ]; then
  source "$HOME/.sel_config"
else
  echo "No .sel_config file found. Using default settings."
  VAR_NAME="s"
  HISTORY_LIMIT=10
  HISTORY_ENABLED="on"
  USE_FULL_PATH="on"
  TRUNCATE_SUFFIX="t"
fi

# Initialize history if enabled
if [ "$HISTORY_ENABLED" == "on" ]; then
  declare -a selected_items=()  # History of selected items (truncated or full based on config)
  declare -a full_items=()      # Full paths for every selected item
  declare -i count=0            # Counter for selected items
fi

# Function sel
sel() {
  selected_item=$(ls -1 | grep -vE '^\.$|^\.\.$' | sed -n "${1}p")

  if [ -z "$selected_item" ]; then
    echo "No item found for number: $1"
    return 1
  fi

  local full_path="$(realpath "$selected_item")"

  if [ "$HISTORY_ENABLED" == "on" ]; then
    # Save based on config
    if [ "$USE_FULL_PATH" == "on" ]; then
      selected_items+=("$full_path")
    else
      selected_items+=("$selected_item")
    fi
    full_items+=("$full_path")
    count=$((count + 1))

    if [ "$count" -gt "$HISTORY_LIMIT" ]; then
      selected_items=("${selected_items[@]:1}")
      full_items=("${full_items[@]:1}")
      count=$((count - 1))
    fi
  fi

  eval "$VAR_NAME=\"$selected_items[-1]\""
  echo "Selected: ${selected_items[-1]}"
}

# Function to retrieve item from history
retrieve_history() {
  local index="$1"
  local suffix="$2"

  if [ -z "${selected_items[$index]}" ]; then
    echo "No item in history for index $index"
    return 1
  fi

  local result=""
  local var_ref="${VAR_NAME}${index}"

  if [ "$suffix" == "$TRUNCATE_SUFFIX" ]; then
    result="${selected_items[$index]}"
    echo "Using truncated path due to override: $result"
  else
    if [ "$USE_FULL_PATH" == "on" ]; then
      result="${full_items[$index]}"
    else
      result="${selected_items[$index]}"
    fi
  fi

  eval "$var_ref=\"$result\""
}

# Optional: allow $s0 to be the most recent
alias "${VAR_NAME}0"="${VAR_NAME}"