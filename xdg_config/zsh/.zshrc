Set the shell to zsh
export SHELL=/bin/zsh

export LANG=en_US.UTF8

## Import locations
export ZSH_CUSTOM=~/.config/zsh/custom/
export ZSH_ENV_HOME=$HOME/

export XDG_CONFIG_HOME=$HOME/.config/

## ZSH options
setopt functionargzero
setopt hist_ignore_space

## ZSH plugins
autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit

source $XDG_CONFIG_HOME/antigen/antigen.zsh

antigen bundle 'zsh-users/zsh-syntax-highlighting'
antigen bundle 'zsh-users/zsh-autosuggestions'
antigen apply

bindkey '^ ' autosuggest-accept
bindkey '^n' autosuggest-accept
# 
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

eval "$(starship init zsh)"
eval "$(atuin init zsh)"
eval "$(keychain --eval --agents ssh id_ed25519)"
eval "$(~/.local/bin/mise activate zsh)"

## files include
sources=(
  'aliases'
  'git'
)

for s in "${sources[@]}"; do
  source $HOME/.config/zsh/include/${s}.zsh
done


export LC_ALL=en_US.UTF-8

export HISTSIZE=100000000
export SAVEHIST=$HISTSIZE
export HISTFILE=$HOME/.local/zsh_history

# Go
if [ -d /usr/local/go/bin/ ]; then
  export GOPATH=~/go
  export GOBIN="$GOPATH/bin"
  export PATH="/usr/local/go/bin:$GOBIN:$PATH"
elif [ -d ~/.go/bin/ ]; then
  export GOPATH="$HOME/.gopath"
  export GOROOT="$HOME/.go"
  export GOBIN="$GOPATH/bin"
  export PATH="$GOPATH/bin:$PATH"
fi

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -f "$HOME/.zsh_local" ]]; then
  source ~/.zsh_local
fi

# Poetry
if [[ -d "$HOME/.poetry/bin/" ]]; then
  export PATH="$HOME/.poetry/bin/:$PATH"
fi

if [[ -d "$XDG_CONFIG_HOME/bin" ]]; then
  export PATH="$XDG_CONFIG_HOME/bin:$PATH"
fi

export PATH="$HOME/.local/bin/:$PATH"