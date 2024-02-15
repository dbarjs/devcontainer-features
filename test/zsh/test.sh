#!/bin/bash

set -e

source dev-container-features-test-lib

# Test ZSH plugins
check "git plugin active" zsh -i -c "echo \$plugins" | grep "git"
check "zsh-autosuggestions plugin active" zsh -i -c "echo \$plugins" | grep "zsh-autosuggestions"
check "zsh-syntax-highlighting plugin active" zsh -i -c "echo \$plugins" | grep "zsh-syntax-highlighting"
check "zsh-z plugin active" zsh -i -c "echo \$plugins" | grep "zsh-z"

# Test ZSH themes
check "spaceship theme installed" zsh -i -c "ls \$ZSH_CUSTOM/themes" | grep "spaceship.zsh-theme"
check "spaceship theme active" zsh -i -c "echo \$ZSH_THEME" | grep "spaceship"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
