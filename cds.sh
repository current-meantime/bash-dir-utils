#!/bin/bash

# 'cd' to 'selected' = 'cds'
# usage: cds [dir number]
# you can get the dir number by running 'lcd' if you don't know it

cds() {
  target=$(ls -1 | sed -n "${1}p")
  if [ -d "$target" ]; then
    cd "$target"
  else
    echo "No directory found with number: $1"
  fi
}
