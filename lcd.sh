#!/bin/bash

# essentially, 'ls' but lines are numbered, takes in normal 'ls' options
# usage: lcd ['ls' options] [path]
# suggested usage: in combination with 'cds' and 'sel' utils

lcd() {
  ls -1 "$@" | nl
}
