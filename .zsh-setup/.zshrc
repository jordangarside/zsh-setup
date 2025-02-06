# IMPORTANT(jg): Test performance of changes with:
#   hyperfine -i -N --warmup 1 "zsh -i -c exit"

# zinit
source ~/.zsh-setup/.zinit.zsh

# Manage ZSH History
HISTSIZE=500000
SAVEHIST=500000
HISTFILE="$HOME/.zsh_history"
setopt   EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format
unsetopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits
setopt   INC_APPEND_HISTORY_TIME   # Write to the history file immediately with timestamp
unsetopt SHARE_HISTORY             # Share history between all sessions
setopt   HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history
setopt   HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
unsetopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
unsetopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt   HIST_IGNORE_SPACE         # Don't record an entry starting with a space
unsetopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file
setopt   HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry
unsetopt BANG_HIST                 # Treat the '!' character specially during expansion
unsetopt HIST_VERIFY               # Don't execute immediately upon history expansion
unsetopt HIST_BEEP                 # Beep when accessing nonexistent history

# Snap
PATH="/snap/bin:$PATH"

# Proto
PROTO_HOME="$HOME/.proto"
PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# Rust
. "$HOME/.cargo/env"

# Go
PATH="$PATH:$HOME/go/bin"
