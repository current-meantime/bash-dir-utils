#!/bin/bash

# a simple way to change directories by selecting from a numbered list
# usage: cds [dir number]
# you can get the dir number by running 'lcd' if you don't know it
# why the name? 'cd' to 'selected' = 'cds'

cds() {
  local input="$1"

  # If input is a number, use it as a list index
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    local target=$(ls -1 | grep -vE '^\.$|^\.\.$' | sed -n "${input}p")
    if [ -d "$target" ]; then
      cd "$target"
    else
      echo "No directory found at position $input"
    fi
  # Otherwise, treat it as a direct path
  elif [ -d "$input" ]; then
    cd "$input"
  else
    echo "Invalid input: '$input' is not a valid directory or list index"
  fi
}
