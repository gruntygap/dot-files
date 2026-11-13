# emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# emulate zsh -c "$(direnv hook zsh)"

# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="vim"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git docker zsh-syntax-highlighting zsh-autosuggestions fzf)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias asu='sudo su - $(whoami)'
alias gpn='git push --set-upstream origin ${${$(git symbolic-ref -q HEAD)##refs/heads/}:-HEAD}'
alias fmt='terraform fmt --recursive'
alias vim='nvim'

# Enable MISE
eval "$(~/.local/bin/mise activate zsh)"
eval "$(~/.local/bin/mise hook-env -s zsh)"
source <(fzf --zsh)

# bun completions
# [ -s "/Users/grantgapinski/.bun/_bun" ] && source "/Users/grantgapinski/.bun/_bun"

# bun
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# Shell function (drop in ~/.zshrc, then call: aires dev|staging|usmc)
source ~/.env

aires() (
  local env=$1 region=us-gov-east-1
  local action=${2:-ssh}

  if [[ -z $env ]]; then
    print -u2 "usage: aires dev|staging|usmc [scp <options> <source> <destination>]"
    return 2
  fi

  case $action in
    ssh)
      if (( $# > 1 )); then
        print -u2 "usage: aires dev|staging|usmc [scp <options> <source> <destination>]"
        return 2
      fi
      ;;
    scp)
      if (( $# < 4 )); then
        print -u2 "usage: aires $env scp <options> <source> <destination>"
        print -u2 "example: aires $env scp ./script.sh :/tmp/"
        return 2
      fi
      ;;
    *)
      print -u2 "aires: unknown action: $action"
      return 2
      ;;
  esac

  # Newest running instance first; several can share the aires-$env Name tag.
  local -a hosts
  hosts=(${(f)"$(aws ec2 describe-instances --region $region \
    --filters "Name=tag:Name,Values=aires-$env" "Name=instance-state-name,Values=running" \
    --query 'reverse(sort_by(Reservations[].Instances[], &LaunchTime))[].PrivateIpAddress' \
    --output text | tr '\t' '\n')"})

  if (( ${#hosts} == 0 )); then
    print -u2 "aires: no running instance tagged aires-$env in $region"
    return 1
  fi
  if (( ${#hosts} > 1 )); then
    print -u2 "aires: ${#hosts} running instances tagged aires-$env; using newest ($hosts[1]) of: $hosts"
  fi

  eval "$(ssh-agent -s)" >/dev/null || return 1
  trap 'kill "$SSH_AGENT_PID" 2>/dev/null' EXIT
  if ! aws secretsmanager get-secret-value --region $region --secret-id "aires/Keypair/$env" \
       --query SecretString --output text | ssh-add -q -t 3600 -; then
    print -u2 "aires: failed to load keypair aires/Keypair/$env"
    return 1
  fi

  local result
  if [[ $action == scp ]]; then
    shift 2
    local -a scp_args
    local arg
    for arg in "$@"; do
      if [[ $arg == :* ]]; then
        scp_args+=("ec2-user@$hosts[1]$arg")
      else
        scp_args+=("$arg")
      fi
    done
    scp "${scp_args[@]}"
    result=$?
  else
    ssh "ec2-user@$hosts[1]"
    result=$?
  fi
  return $result
)

source ~/scripts/fzf-git.sh/fzf-git.sh

