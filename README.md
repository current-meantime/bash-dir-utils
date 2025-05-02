# Directory Utilities: `lcd`, `cds`, and `sel`

This package contains three utilities to enhance directory navigation and selection:

- **`lcd`**: List files and directories with numbered output.
- **`cds`**: Change to a directory by number (without history).
- **`sel`**: Select and store files/directories with history tracking.

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
  - [lcd](#lcd)
  - [cds](#cds)
  - [sel](#sel)
- [Configuration](#configuration)

## Introduction

The utilities help with directory navigation and file management. You can list files and directories with numbers, select them by number, and keep a history of your selections to use the selections in other commands.

## Installation

1. Download the utilities and save them to a directory, e.g., `~/bin/` or `~/scripts/`. Don't forget the `.sel_config`.
2. Make sure the utilities are executable:

    ```bash
    chmod +x lcd.sh cds.sh sel.sh
    ```

3. Add the following lines to your `~/.bashrc` or `~/.zshrc` to load the scripts:

    ```bash
    # Add custom scripts to PATH
    export PATH="$HOME/bin:$PATH"
    
    # Load utilities
    source ~/bin/lcd.sh
    source ~/bin/cds.sh
    source ~/bin/sel.sh
    ```

4. Reload your shell:

    ```bash
    source ~/.bashrc  # or source ~/.zshrc for Zsh users
    ```

## Usage

### `lcd`

`lcd` lists files and directories, displaying them with numbers for easy reference.
If you wish, you can use standard `ls` flags after `lcd`.

You may want to use `lcd` before `sel`, to know for sure what item you're selecting, or before `cds` for a directory number.

```bash
lcd [options]
```
Usage example with output:
```bash
current@orangepizero2w:~/example$ lcd
     1  file.txt
     2  my_dir
     3  my_second_dir
```
### `cds`
`cds` allows you to change directories by specifying a number. You can check the number by running `lcd`. You can also enhance `cds` with `sel` - select an item with `sel` and pass it to `cds` to easly navigate to directories outside your current one, with minimal typing and no copy-pasting by hand.

```bash
cds [dir_number]
```
Example:
```bash
cds 2
```
### `sel`
`sel` allows you to select files or directories by number, store them in history, and reuse them in commands. By default, it copies the full path of an item. This behavior can be changed.
You can combine `sel` with `lcd` to clearly see what you're selecting, and with `cds` to jump to directories beyond the ones contained in your current one (the default behavior of `cds`).
```bash
sel [item_number]
```
### Usage
```bash
lcd           # List all items with line numbers
sel 2         # Select item number 2 and store it in variable (default: $s)
echo $s       # Reference the selected item (full path or relative, depending on config)
echo $st      # Reference the same item with truncation
sel 3         # Select item number 3
echo $s1t     # Reference the PREVIOUSLY selected item (item 2 - from sel history) (relative path)
cd ..
cdx $s        # Reference item number 3 (the most recent seletion) and jump to this directory 
```
### History Access
You can reference earlier selections using:
```bash
$s0           # Most recent selection (same as $s)
$s1           # Second most recent
$s2           # Third most recent, etc.
```
History limit can be changed in `.sel_config`.
### Truncation - Override Full Paths
Truncated path means the relative path of the selected item, as opposed to the full absolute path.

If your config uses full paths by default, but you want a short name for one command:
```bash
$s2t          # Use the truncated name of the 3rd most recent selection
```
You can also customize the suffix (t) in your `.sel_config` file:
```bash
TRUNCATE_SUFFIX="short"          # changed from the default 't'
```
Then use `$s1short`.

You can change the default `s` and other options as well - see the next section.

### Configuration
Edit (or create) ~/.sel_config:
```bash
VAR_NAME="s"           # Base name of the variable to store selections
HISTORY_LIMIT=10       # Max number of recent selections to store
HISTORY_ENABLED="on"   # Enable/disable history
USE_FULL_PATH="on"     # Store full file paths (default "on")
TRUNCATE_SUFFIX="t"    # Suffix for using truncated names
```