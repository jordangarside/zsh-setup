#!/usr/bin/env zsh

if ! (($+commands[lsd])); then
    return
fi

# Create alias override commands using 'lsd'
alias ls='lsd --group-directories-first'
alias ll='lsd -l --group-directories-first'
alias la='lsd -la --group-directories-first'
alias lt='lsd -l --group-directories-first --tree --depth=2'
