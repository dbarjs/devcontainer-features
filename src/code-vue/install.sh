#!/bin/bash

set -e

USERNAME=${USERNAME:-$_REMOTE_USER}

echo "Installing Code Vue feature for the user '$USERNAME'"

create_indicator_file() {
  local LOCATION="/home/$USERNAME"

  # check if the directory exists
  if [ ! -d "$LOCATION" ]; then
    echo "The directory $LOCATION does not exist"
    exit 1
  fi

  local FILE_PATH="$LOCATION/.code-vue"

  touch "$FILE_PATH"
  chown "$USERNAME:$USERNAME" "$FILE_PATH"
}

# check root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script should not be run as root"
  exit 1
fi

# create a simple file to indicate that the feature is installed
create_indicator_file
