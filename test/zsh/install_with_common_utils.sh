#!/bin/bash

set -e

source dev-container-features-test-lib

# Define plugin URLs
plugin_urls=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/agkozak/zsh-z"
)

# Define plugin list
plugin_list="git zsh-autosuggestions zsh-syntax-highlighting zsh-z"

# Test if plugins are correctly cloned into oh-my-zsh directory
for url in "${plugin_urls[@]}"; do
    # Extract plugin name from URL
    plugin_name=$(basename "$url")

    # Check if plugin directory exists in oh-my-zsh plugins directory
    check "'$plugin_name' plugin cloned" test -d "$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
done

# Test if plugins are correctly configured in .zshrc
for plugin_name in $plugin_list; do
    # Check if plugin is present in .zshrc
    check "'$plugin_name' plugin configured" grep -q "^\s*plugins=.*\b$plugin_name\b" "$HOME/.zshrc"
done

# Test if spaceship theme is correctly cloned, linked and configured in .zshrc
check "spaceship theme cloned" test -d "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
check "spaceship theme linked" test -L "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme"
check "spaceship theme configured" grep -q "^\s*ZSH_THEME=\"spaceship\"" "$HOME/.zshrc"

# Test command history configuration
COMMAND_HISTORY_LOCATION="/commandhistory"
BASH_HISTORY_FILENAME=".bash_history"
ZSH_HISTORY_FILENAME=".zsh_history"

# Check if command history location exists
check "command history location created" test -d "$COMMAND_HISTORY_LOCATION"

# Check if BASH history file exists
check "BASH history file created" test -f "$COMMAND_HISTORY_LOCATION/$BASH_HISTORY_FILENAME"

# Check if ZSH history file exists
check "ZSH history file created" test -f "$COMMAND_HISTORY_LOCATION/$ZSH_HISTORY_FILENAME"

# Test if BASH history is correctly configured finding if has `HISTFILE=/commandhistory/.bash_history` in any part of .bashrc
check "BASH history configured" grep -q "HISTFILE=$COMMAND_HISTORY_LOCATION/$BASH_HISTORY_FILENAME" "$HOME/.bashrc"

# Test if ZSH history is correctly configured finding if has `HISTFILE=/commandhistory/.zsh_history` in any part of .zshrc
check "ZSH history configured" grep -q "HISTFILE=$COMMAND_HISTORY_LOCATION/$ZSH_HISTORY_FILENAME" "$HOME/.zshrc"

cat "$HOME/.zshrc"

reportResults

