#!/bin/bash

# This script provides a simple way to select files or directories from the current directory.
# It allows you to select an item by its line number and store it in a variable (by default 's')
# to reuse it in other commands.

# Usage: sel [item number] / s[item number][optional truncation suffix]
# Example:
# sel 2
# echo $s2t

# It's recommended to use this in combination with the 'lcd' utility
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

# Ensure HISTORY_LIMIT is an integer
if ! [[ "$HISTORY_LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Invalid HISTORY_LIMIT value. Defaulting to 10."
  HISTORY_LIMIT=10
fi

# Declare arrays conditionally
if [ "$HISTORY_ENABLED" == "on" ]; then
  declare -a selected_items=()
  declare -a full_items=()
  declare -i count=0
fi

# Define the sel function
sel() {
  selected_item=$(ls -1 | grep -vE '^\.$|^\.\.$' | sed -n "${1}p")

  if [ -z "$selected_item" ]; then
    echo "No item found for number: $1"
    return 1
  fi

  local full_path="$(realpath "$selected_item")"

  if [ "$HISTORY_ENABLED" == "on" ]; then
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

    # Update all $s, $s0, $s1, etc. variables with bounds checking
    for N in $(seq 0 $((HISTORY_LIMIT - 1))); do
      if [ "$N" -lt "$count" ]; then
        local idx=$((count - N - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#selected_items[@]}" ]; then
          var_ref="${VAR_NAME}${N}"
          if [ "$USE_FULL_PATH" == "on" ] && [ "$idx" -lt "${#full_items[@]}" ]; then
            val="${full_items[$idx]}"
          else
            val="${selected_items[$idx]}"
          fi
          # Use eval safely to assign variable
          eval "$var_ref"='$val'
          if [ "$N" -eq 0 ]; then
            eval "$VAR_NAME"='$val'
          fi
        fi
      else
        break
      fi
    done
  fi


  echo "Selected: ${selected_item}"
}