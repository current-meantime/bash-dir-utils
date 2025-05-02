#!/bin/bash

# this script provides a simple way to select files or directories from the current directory.
# it allows you to select an item by its number and store it in a variable.
# usage: sel [item number]
# example: sel 2
# it's recommended to use this in combination with the 'lcd' utility
# which lists files and directories with line numbers.

# load configuration
if [ -f "$HOME/.sel_config" ]; then
  source "$HOME/.sel_config"
else
  echo "No .sel_config file found. Using default settings."
  VAR_NAME="s"
  HISTORY_LIMIT=10
  HISTORY_ENABLED="on"
fi

# initialize history if enabled
if [ "$HISTORY_ENABLED" == "on" ]; then
  declare -a selected_items=()  # history of selected items
  declare -i count=0            # counter for the number of selected items
fi

# function sel
sel() {
  # exclude . and .., number files and directories
  selected_item=$(ls -1 | grep -vE '^\.$|^\.\.$' | sed -n "${1}p")
  
  # check if something was found
  if [ -z "$selected_item" ]; then
    echo "No item found for number: $1"
    return 1
  fi
  
  # add the selected item to the history if history is enabled
  if [ "$HISTORY_ENABLED" == "on" ]; then
    # add item to the history array
    selected_items+=("$selected_item")
    count=$((count + 1))

    # if we exceed the history limit, remove the oldest element
    if [ "$count" -gt "$HISTORY_LIMIT" ]; then
      selected_items=("${selected_items[@]:1}")
      count=$((count - 1))
    fi
  fi

  # assign selected item to the variable (e.g., s, s1, s2...)
  eval "$VAR_NAME=\"$selected_item\""
  
  # confirmation
  echo "Selected: $selected_item"
}

# function to retrieve item from history
retrieve_history() {
  # argument is the history index (e.g., 0, 1, 2...)
  local history_index=$1
  
  if [ -z "${selected_items[$history_index]}" ]; then
    echo "No item in history for index $history_index"
    return 1
  fi
  
  eval "$VAR_NAME=\"${selected_items[$history_index]}\""
  echo "Retrieved: $VAR_NAME"
}
