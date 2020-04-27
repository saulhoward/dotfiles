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

alias ls='gls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
alias ll='gls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'

# tmux assume 256 colour
alias tmux='tmux -2'
alias ta='tmux attach'

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
## GVM (go version manager)
[[ -s "/home/saul/.gvm/scripts/gvm" ]] && source "/home/saul/.gvm/scripts/gvm"

# chromium hidpi fix
# alias chromium='chromium --force-device-scale-factor=1.25'
export PATH="/usr/local/opt/tcl-tk/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/saulhoward/google-cloud/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/saulhoward/google-cloud/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/saulhoward/google-cloud/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/saulhoward/google-cloud/google-cloud-sdk/completion.zsh.inc'; fi

# gcloud
export GOOGLE_APPLICATION_CREDENTIALS="/Users/saulhoward/google-cloud/keys/deepdrama-afbe3ed48938.json"

DISABLE_AUTO_TITLE="true"
function precmd () {
  window_title="\033]0;${PWD##*/}\007"
  echo -ne "$window_title"
}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
