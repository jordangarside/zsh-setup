#!/usr/bin/env zsh
# https://github.com/romkatv/powerlevel10k/blob/8fa10f43a0f65a5e15417128be63e68e1d5b1f66/config/p10k-robbyrussell.zsh
# Config file for Powerlevel10k with the style of robbyrussell theme from Oh My Zsh.
#
# Original: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#robbyrussell.
#
# Replication of robbyrussell theme is exact. The only observable difference is in
# performance. Powerlevel10k prompt is very fast everywhere, even in large Git repositories.
#
# Usage: Source this file either before or after loading Powerlevel10k.
#
#   source ~/powerlevel10k/config/p10k-robbyrussell.zsh
#   source ~/powerlevel10k/powerlevel10k.zsh-theme

# Temporarily change options.
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Unset all configuration options.
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # Zsh >= 5.1 is required.
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Left prompt segments.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    prompt_char
    dir
    vcs
  )
  # Right prompt segments.
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    aws                  # AWS profile
    azure                # Azure
    gcloud               # Google Cloud
    go_version           # Go version
    java_version         # Java version
    kubecontext          # Kubernetes context
    node_version         # Node.js version
    pyenv                # Python version
    rust_version         # Rust version
    terraform            # Terraform workspace
    virtualenv           # Python version
  )

  function custom_preexec() {
    # Save information about the current command to show
    #   command duration and start time after the command finishes
    # NOTE(jg): https://apple.stackexchange.com/a/359718
    command_start_time=$(perl -MTime::HiRes -e 'printf("%.9f\n", Time::HiRes::time())') # e.g. 1738805792.451287031
    command_start_formatted=$(date '+%I:%M:%S%p') # e.g. 12:00:00AM
  }

  function custom_precmd() {
    # Print the duration and start time of the most recent command
    # before showing the current prompt
    local GREY='%F{242}'   # 7 chars
    local YELLOW='%B%F{3}' # 7 chars
    local RESET='%b%f'     # 4 chars
    local TERMINAL_WIDTH=$(( COLUMNS ))
    local text="at ${GREY}$(date '+%I:%M:%S%p')${RESET}"
    local color_char_count=$(( 7 + 4 ))

    if (( ${+command_start_time} )); then
      local command_end_time=$(perl -MTime::HiRes -e 'printf("%.9f\n", Time::HiRes::time())')
      local duration=$(( $command_end_time - $command_start_time ))
      unset command_start_time

      if (( duration >= 1 )); then
        local formatted_duration=$(printf "%.2f" "$duration")
        text="took ${YELLOW}${formatted_duration}s${RESET} at ${GREY}${command_start_formatted}${RESET}"
        color_char_count=$(( 7 + 4 + 7 + 4 ))
      fi
      unset command_start_formatted
    fi

    # This pads 'text' on the left with spaces until the total printed width is TERMINAL_WIDTH.
    print -P "${(l:$(( TERMINAL_WIDTH + color_char_count )):)text}"
  }

  # Add both hooks
  preexec_functions+=(custom_preexec)
  precmd_functions+=(custom_precmd)

  # Basic style options that define the overall prompt look.
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no segment icons

  # Add these lines to disable prompt connection and ruler
  typeset -g POWERLEVEL9K_SHOW_RULER=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '

  # Green prompt symbol if the last command succeeded.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=green
  # Red prompt symbol if the last command failed.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=red
  # Prompt symbol: bold arrow.
  typeset -g POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION='%B➜ '

  # Cyan current directory.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=cyan
  # Show only the last segment of the current directory.
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
  # Bold directory.
  typeset -g POWERLEVEL9K_DIR_CONTENT_EXPANSION='%B$P9K_CONTENT'

  # Git status formatter.
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      # If P9K_CONTENT is not empty, it's either "loading" or from vcs_info (not from
      # gitstatus plugin). VCS_STATUS_* parameters are not available in this case.
      typeset -g my_git_format=$P9K_CONTENT
    else
      # Use VCS_STATUS_* parameters to assemble Git status. See reference:
      # https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
      typeset -g my_git_format="${1+%B%4F}"$'\uf418'" ${1+%1F}"
      my_git_format+=${${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_COMMIT[1,8]}}//\%/%%}
      my_git_format+="${1+%4F}"
      if (( VCS_STATUS_NUM_CONFLICTED || VCS_STATUS_NUM_STAGED ||
            VCS_STATUS_NUM_UNSTAGED   || VCS_STATUS_NUM_UNTRACKED )); then
        my_git_format+=" ${1+%3F}✗"
      fi
    fi
  }
  functions -M my_git_formatter 2>/dev/null

  # Disable the default Git status formatting.
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  # Install our own Git status formatter.
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter()))+${my_git_format}}'
  # Grey Git status when loading.
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=246

  # Instant prompt mode.
  #
  #   - off:     Disable instant prompt. Choose this if you've tried instant prompt and found
  #              it incompatible with your zsh configuration files.
  #   - quiet:   Enable instant prompt and don't print warnings when detecting console output
  #              during zsh initialization. Choose this if you've read and understood
  #              https://github.com/romkatv/powerlevel10k#instant-prompt.
  #   - verbose: Enable instant prompt and print a warning when detecting console output during
  #              zsh initialization. Choose this if you've never tried instant prompt, haven't
  #              seen the warning, or if you are unsure what this all means.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
  # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
  # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
  # really need it.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # If p10k is already loaded, reload configuration.
  # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
  (( ! $+functions[p10k] )) || p10k reload

  #############[ aws: aws profile ]#############
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws'
  typeset -g POWERLEVEL9K_AWS_FOREGROUND=208  # orange
  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='%B☁️ AWS ${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'

  #############[ azure: azure account ]#############
  typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az'
  typeset -g POWERLEVEL9K_AZURE_FOREGROUND=31  # azure blue
  typeset -g POWERLEVEL9K_AZURE_CONTENT_EXPANSION='%B⚡ Azure ${P9K_AZURE_SUBSCRIPTION_NAME//\%/%%}'

  #############[ gcloud: google cloud cli account and project ]#############
  typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gsutil'
  typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=32  # blue
  typeset -g POWERLEVEL9K_GCLOUD_CONTENT_EXPANSION='%B🌥️ GCP ${P9K_GCLOUD_PROJECT_ID//\%/%%}'

  #############[ go_version: go version ]#############
  typeset -g POWERLEVEL9K_GO_VERSION_SHOW_ON_COMMAND='go|gomod|godoc|gore'
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=45  # light blue
  typeset -g POWERLEVEL9K_GO_VERSION_CONTENT_EXPANSION='%B🐹 v$P9K_CONTENT'
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=false

  #############[ java_version: java version ]#############
  typeset -g POWERLEVEL9K_JAVA_VERSION_SHOW_ON_COMMAND='java|javac|gradle|maven|mvn'
  typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND=178  # gold
  typeset -g POWERLEVEL9K_JAVA_VERSION_CONTENT_EXPANSION='%B☕ v$P9K_CONTENT'
  typeset -g POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY=false

  #############[ kubecontext: current kubernetes context ]#############
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s'
  typeset -g POWERLEVEL9K_KUBECONTEXT_FOREGROUND=32  # blue
  typeset -g POWERLEVEL9K_KUBECONTEXT_CONTENT_EXPANSION='%B☸️ ${P9K_KUBECONTEXT_CLUSTER:-}/${P9K_KUBECONTEXT_NAMESPACE:-}'

  ##############################[ node_version: node version ]###############################
  typeset -g POWERLEVEL9K_NODE_VERSION_SHOW_ON_COMMAND='node|npm|yarn|pnpm'
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70  # green
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=false
  typeset -g POWERLEVEL9K_NODE_VERSION_CONTENT_EXPANSION='%B⬢ v$P9K_CONTENT'

  #############[ pyenv: python version ]#############
  typeset -g POWERLEVEL9K_PYENV_SHOW_ON_COMMAND='python|python3|pip|pip3|poetry|pytest|pyenv'
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=37  # teal
  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='%B🐍 $P9K_CONTENT'
  # Hide python version if it doesn't come from one of these sources.
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local global)
  # If set to false, hide python version if it's the same as global:
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=true
  # If set to false, hide python version if it's equal to "system".
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=false

  #############[ rust_version: rust version ]#############
  typeset -g POWERLEVEL9K_RUST_VERSION_SHOW_ON_COMMAND='rust|rustc|cargo|rustup'
  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=166  # rust orange
  typeset -g POWERLEVEL9K_RUST_VERSION_CONTENT_EXPANSION='%B🦀 v$P9K_CONTENT'
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=false

  #############[ terraform: terraform workspace ]#############
  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_ON_COMMAND='terraform|tf|cdktf'
  typeset -g POWERLEVEL9K_TERRAFORM_FOREGROUND=105  # purple
  typeset -g POWERLEVEL9K_TERRAFORM_CONTENT_EXPANSION='%B💠 ${P9K_TERRAFORM_WORKSPACE//\%/%%}'

  #############[ virtualenv: python virtual environment ]#############
  typeset -g POWERLEVEL9K_PYTHON_VERSION_SHOW_ON_COMMAND='python|python3|pip|pip3|poetry|pytest'
  typeset -g POWERLEVEL9K_PYTHON_VERSION_FOREGROUND=37  # teal
  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='%B🐍 $P9K_CONTENT'
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV="if-different"

  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
