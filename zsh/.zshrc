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
 
autoload -U colors && colors
PROMPT="%{$fg[green]%}%n@%m %{$fg[yellow]%}>> %{$reset_color%}"
RPROMPT=" %{$fg[blue]%}%~%{$reset_color%}"

export PATH=$PATH:/home/saul/bin:/usr/local/bin
export PATH=$PATH:/usr/bin/vendor_perl

export EDITOR=vim
export VISUAL=vim

alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
alias ll='ls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'

# tmux assume 256 colour
alias tmux='tmux -2'
alias ta='tmux attach'

# chromium hidpi fix
alias chromium='chromium --force-device-scale-factor=1.25'

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
## GVM (go version manager)
[[ -s "/home/saul/.gvm/scripts/gvm" ]] && source "/home/saul/.gvm/scripts/gvm"

# X
#xrdb -load ~/.Xresources