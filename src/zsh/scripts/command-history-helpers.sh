#!/bin/bash

BASH_HISTORY_FILENAME=".bash_history"
ZSH_HISTORY_FILENAME=".zsh_history"

create_command_history_location() {
  echo "Creating command history location..."

  local COMMAND_HISTORY_LOCATION="$1"

  if ! [ -d "$COMMAND_HISTORY_LOCATION" ]; then
    mkdir -p "$COMMAND_HISTORY_LOCATION"
  fi

  touch "$COMMAND_HISTORY_LOCATION/$BASH_HISTORY_FILENAME"
  touch "$COMMAND_HISTORY_LOCATION/$ZSH_HISTORY_FILENAME"

  chown -R $USERNAME $COMMAND_HISTORY_LOCATION
}

config_bash_history() {
  echo "Configuring BASH history..."

  local BASH_CONFIG_LOCATION="$1"
  local COMMAND_HISTORY_LOCATION="$2"

  # create configuration file if not exists
  if ! [ -f "$BASH_CONFIG_LOCATION" ]; then
    mkdir -p "$(dirname "$BASH_CONFIG_LOCATION")" && touch "$BASH_CONFIG_LOCATION"
  fi

  # Add history file location to bash config
  SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=$COMMAND_HISTORY_LOCATION/$BASH_HISTORY_FILENAME "
  echo "$SNIPPET" >> "$BASH_CONFIG_LOCATION"
}

config_zsh_history() {
  # check if zsh is installed
  if ! type zsh >/dev/null 2>&1; then
    echo "ZSH is not installed. Skipping..."
    return
  fi

  echo "Configuring ZSH history..."

  local ZSH_CONFIG_LOCATION="$1"
  local COMMAND_HISTORY_LOCATION="$2"

  # Add history file location to zsh config
  SNIPPET="export HISTFILE=$COMMAND_HISTORY_LOCATION/$ZSH_HISTORY_FILENAME "
  echo "$SNIPPET" >> "$ZSH_CONFIG_LOCATION"
}
