#!/bin/bash

# NOW(jg): Should there be a separate zinit and env variable zsh scripts so they can be
#          enabled/commented out separately?

ORIGINAL_DIR=$(pwd)
# cd to script directory
cd "$(dirname "$0")" || exit 1

source ./common.sh

echo "🐚 Setting up ZSH environment..."

# Sync .zsh-setup directory, only copying changed files
execute_step "rsync -a --delete .zsh-setup/ $HOME/.zsh-setup/" "Update .zsh-setup directory"

# Ensure .zsh-setup/.zshrc is sourced in .zshrc
ZSHSETUPRC_SOURCE_LINE="[ -f ~/.zsh-setup/.zshrc ] && source ~/.zsh-setup/.zshrc"
ZSHSETUPRC_SOURCE_BLOCK="# Added by zsh-setup setup script\n$ZSHSETUPRC_SOURCE_LINE\n"
if ! grep -q "$ZSHSETUPRC_SOURCE_LINE" ~/.zshrc; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ZSHRC="$HOME/.zshrc"
    BACKUP="$HOME/.zshrc.$TIMESTAMP.backup"

    if [ -f "$ZSHRC" ]; then
        execute_step "mv $ZSHRC $BACKUP" "Back up existing .zshrc to $BACKUP"
        execute_step "echo -e '$ZSHSETUPRC_SOURCE_BLOCK' > $ZSHRC && cat $BACKUP >> $ZSHRC" "Create new .zshrc with zsh-setup source"
    else
        execute_step "echo -e '$ZSHSETUPRC_SOURCE_BLOCK' > $ZSHRC" "Create new .zshrc with zsh-setup source"
    fi
else
    echo "    ⏩ ~/.zsh-setup/.zshrc already sourced in .zshrc"
fi

# Setup zsh if not already the login shell
if ! echo "$SHELL" | grep -q "zsh"; then
    execute_step "sudo chsh -s $(which zsh) $USER" "Set zsh as login shell"
fi

# Return to original directory before starting new zsh session
cd "$ORIGINAL_DIR" || exit 1

# Start a new zsh session
echo -e "✅ ZSH setup complete!\n"
echo -e "👉 Try starting a new ZSH session with ${BOLD}'zsh'${RESET}"
