#!/bin/zsh

SHARE_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
ZINIT_HOME="${SHARE_HOME}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# https://github.com/zdharma-continuum/zinit/issues/647#issuecomment-2595751062
mkdir -p $ZSH_CACHE_DIR/completions
fpath=($ZSH_CACHE_DIR/completions $fpath)

# Load powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k
source ~/.zsh-setup/themes/minimal.p10k.zsh

# Load oh-my-zsh plugins
zinit snippet OMZP::command-not-found
zinit snippet OMZP::git
zinit snippet OMZP::kubectl
zinit snippet OMZP::gcloud
zinit snippet OMZP::docker

# Load external plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light MichaelAquilina/zsh-you-should-use # show alias you could have used
zinit light hlissner/zsh-autopair              # pair quotes, parens, etc.
zinit light Aloxaf/fzf-tab                     # fzf for tab completion

# fzf -- fuzzy history search
zinit ice wait'0c' as'command' lucid \
  from'gh-r' \
  nocompile \
  atclone'./fzf --zsh > fzf.zsh' \
  atpull'%atclone' \
  src'fzf.zsh'
zinit light junegunn/fzf

# zoxide -- smarter `cd` command `z`
zinit ice wait'0c' as'command' lucid \
  from'gh-r' \
  nocompile \
  atclone'./zoxide init zsh > init.zsh' \
  atpull'%atclone' \
  src'init.zsh'
zinit light ajeetdsouza/zoxide

# Manual Aliases
source ~/.zsh-setup/plugins/lsd.zsh # replace ls with lsd

autoload -Uz compinit; compinit

zinit cdreplay -q

eval "$(${SHARE_HOME}/zinit/plugins/ajeetdsouza---zoxide/zoxide init zsh)"
