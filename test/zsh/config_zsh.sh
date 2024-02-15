#!/bin/bash

set -e

source dev-container-features-test-lib

# Test ZSH plugins
check "zsh-autosuggestions plugin active" zsh -i -c "echo \$plugins" | grep "zsh-autosuggestions"
check "zsh-syntax-highlighting plugin active" zsh -i -c "echo \$plugins" | grep "zsh-syntax-highlighting"
check "zsh-z plugin active" zsh -i -c "echo \$plugins" | grep "zsh-z"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
