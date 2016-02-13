HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -v
export KEYTIMEOUT=1
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward

zstyle :compinstall filename '/home/saul/.zshrc'
autoload -U compinit promptinit
compinit
promptinit

fpath=(/usr/local/share/zsh-completions $fpath)
 
autoload -U colors && colors
PROMPT="%{$fg[green]%}%n@%m %{$fg[yellow]%}>> %{$reset_color%}"
RPROMPT=" %{$fg[blue]%}%~%{$reset_color%}"

export PATH=$PATH:/home/saul/bin:/usr/local/bin
export PATH=$PATH:/usr/bin/vendor_perl

alias vim=nvim
export VISUAL=nvim
export EDITOR="$VISUAL"

# alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
# alias ll='ls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'

# tmux assume 256 colour
alias tmux='tmux -2'
alias ta='tmux attach'

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
## GVM (go version manager)
#[[ -s "/home/saul/.gvm/scripts/gvm" ]] && source "/home/saul/.gvm/scripts/gvm"
export GO15VENDOREXPERIMENT=1

# chromium hidpi fix
# alias chromium='chromium --force-device-scale-factor=1.25'

export NVM_DIR="/Users/saul.howard/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

alias docker-init="source /Applications/Docker/Docker\ Quickstart\ Terminal.app/Contents/Resources/Scripts/start.sh"
ulimit -n 65536
ulimit -u 2048

# If you installed the SDK via Homebrew, otherwise ~/Library/Android/sdk
export ANDROID_HOME=/usr/local/opt/android-sdk
