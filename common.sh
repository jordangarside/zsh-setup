#!/bin/bash

# Add ANSI escape codes for bold text
BOLD='\033[1m'
RESET='\033[0m'

# Function to execute command and show status
execute_step() {
    local commands="$1"
    local step_name="$2"

    # Show spinner while running
    echo -n "    ⏳ $step_name"

    # Execute commands and capture output
    output=$(eval "$commands" 2>&1)
    status=$?

    # Clear the spinner line
    echo -ne "\r\033[K"

    if [ $status -eq 0 ]; then
        echo "    ✅ $step_name"
    else
        echo "    ❌ $step_name"
        echo "Error output:"
        echo "$output"
        exit 1
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed (supports brew and apt)
package_installed() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Check if package is installed via Homebrew
        brew list "$1" >/dev/null 2>&1
    else
        # Check if package is installed via apt (debian-specific)
        dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"
    fi
}