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

alias vim=nvim

alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
alias ll='ls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'

# tmux assume 256 colour
alias tmux='tmux -2'
alias ta='tmux attach'

# chromium hidpi fix
alias chromium='chromium --force-device-scale-factor=1.25'

# Go
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
## GVM (go version manager)
[[ -s "/home/saul/.gvm/scripts/gvm" ]] && source "/home/saul/.gvm/scripts/gvm"

# Ruby
export PATH=$PATH:/home/saul/.gem/ruby/2.2.0/bin

# X
#xrdb -load ~/.Xresources
#

# Docker
export DOCKER_HOST=unix:///var/run/docker.sock

# Product Health

# Auth0
export AUTH0_V2_CLIENTID=Yrvl1Np4xMfkBYiC3gVOnZIrXUBpQiRw
export AUTH0_V2_CLIENTSECRET=2V9zKIQFzitlg1rtC_oCiTBM1CYKy3zzIJhflJKcR11wJm48rxVJVTgqJgY-wShD

export AUTH0_CLIENTID=ouOA8EhnjK3vT3IEXK2H8xiMqNphphpF
export AUTH0_CLIENTSECRET=CJik8JKDGAe_od82iYdpKrix468RuMRA3Lldhc7zl_J5OllXhdWAd8RS1mA2ltZy
export AUTH0_DOMAIN=ci-producthealth.auth0.com
export AUTHO_CONNECTION=Username-Password-Authentication

export ACCOUNT_API_ENDPOINT=https://account.ci.phs.io

# Postgres
export PGHOST=postgres
export PGUSER=account
export PGPASSWORD=account
export PGDATABASE=account


