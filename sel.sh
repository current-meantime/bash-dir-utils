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
  # Default settings
  VAR_NAME="s"
  HISTORY_LIMIT=10
  HISTORY_ENABLED="on"
  USE_FULL_PATH="on"
  TRUNCATE_SUFFIX="t"
fi

# Ensure HISTORY_LIMIT is an integer
if ! [[ "$HISTORY_LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Invalid HISTORY_LIMIT. Defaulting to 10."
  HISTORY_LIMIT=10
fi

# Declare arrays conditionally
if [ "$HISTORY_ENABLED" == "on" ]; then
  declare -a selected_items=()
  declare -a full_items=()
  declare -i count=0
fi

# Function to retrieve history with suffix support
function retrieve_history() {
  local index=${1:-0}
  local suffix=${2:-""}
  local item_path

  if [ "$index" -lt 0 ] || [ "$index" -ge "$count" ]; then
    echo "Invalid index: $index. Available range: 0-$((count - 1))"
    return 1
  fi

  # Map history level (0 = latest) to correct array index
  local array_index=$((count - 1 - index))
  item_path="${full_items[$array_index]}"

  case "$suffix" in
    t) echo "${item_path##*/}" ;;  # Truncate to filename
    d) echo "${item_path%/*}" ;;  # Truncate to directory
    *) echo "$item_path" ;;
  esac
}


# Define sel function
function sel() {
  selected_item=$(ls -1 | grep -vE '^\.$|^\.\.$' | sed -n "${1}p")
  if [ -z "$selected_item" ]; then
    echo "No item found for number: $1"
    return 1
  fi

  local full_path="$(realpath "$selected_item")"

  # Update history arrays
  if [ "$HISTORY_ENABLED" == "on" ]; then
    if [ "$USE_FULL_PATH" == "on" ]; then
      selected_items+=("$full_path")
    else
      selected_items+=("$selected_item")
    fi
    full_items+=("$full_path")
    count=$((count + 1))

    # Enforce history limit
    if [ "$count" -gt "$HISTORY_LIMIT" ]; then
      selected_items=("${selected_items[@]:1}")
      full_items=("${full_items[@]:1}")
      count=$((count - 1))
    fi

    # Set $s, $s0, $s1, etc., and truncated versions
    for N in $(seq 0 $((HISTORY_LIMIT - 1))); do
      if [ "$N" -lt "$count" ]; then
        local idx=$((count - N - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#selected_items[@]}" ]; then
          var_ref="${VAR_NAME}${N}"
          val="${full_items[$idx]}"
          eval "$var_ref"='$val'

          # Set base variable ($s) and truncated base variable ($st)
          if [ "$N" -eq 0 ]; then
            eval "$VAR_NAME"='$val'

            if [ -n "$TRUNCATE_SUFFIX" ]; then
              truncated_val=$(retrieve_history 0 "$TRUNCATE_SUFFIX")
              eval "${VAR_NAME}${TRUNCATE_SUFFIX}"='$truncated_val'
            fi
          fi

          # Generate truncated indexed variables ($s0t, $s1t, etc.)
          if [ -n "$TRUNCATE_SUFFIX" ]; then
            truncated_val=$(retrieve_history "$N" "$TRUNCATE_SUFFIX")
            eval "${var_ref}${TRUNCATE_SUFFIX}"='$truncated_val'
          fi
        fi
      else
        break
      fi
    done
  fi

  echo "Selected: ${selected_item}"
}