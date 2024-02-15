#!/bin/bash

# https://spaceship-prompt.sh/getting-started/#Installing
install_spaceship_theme() {
  local THEMES_LOCATION="$1"
  local ZSH_CONFIG_LOCATION="$2"

  mkdir -p "$THEMES_LOCATION"

  # check if spaceship theme is already cloned, if so, clone
  if ! [ -d "$THEMES_LOCATION/spaceship-prompt" ]; then
    echo "Cloning spaceship theme..."
    
    # clone spaceship theme
    git clone --depth 1 https://github.com/spaceship-prompt/spaceship-prompt.git "$THEMES_LOCATION/spaceship-prompt"

    # create symlink
    ln -s "$THEMES_LOCATION/spaceship-prompt/spaceship.zsh-theme" "$THEMES_LOCATION/spaceship.zsh-theme"
  fi

  # check if spaceship theme is already configured, if so, skip
  if [ -f "$THEMES_LOCATION/spaceship.zsh-theme" ]; then
    echo "Spaceship theme already configured. Skipping..."
    return
  fi

  echo "Installing ZSH spaceship theme..."

  # set spaceship theme
  sed -i '/^ZSH_THEME/c\ZSH_THEME="spaceship"' "$ZSH_CONFIG_LOCATION"
}
