HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -v
export KEYTIMEOUT=1
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward

zstyle :compinstall filename '/home/saul/.zshrc'
autoload -U compinit promptinit
compinit -u
promptinit
 
autoload -U colors && colors
PROMPT="%{$fg[green]%}%n@%m %{$fg[yellow]%}>> %{$reset_color%}"
RPROMPT=" %{$fg[blue]%}%~%{$reset_color%}"

export PATH=$PATH:/Users/saulhoward/bin:/usr/local/bin
export PATH=/usr/local/bin:/usr/local/sbin:${PATH}
export PATH=$PATH:/usr/bin/vendor_perl
export PATH=$PATH:/Users/saulhoward/Library/Python/2.7/bin
export PATH=$PATH:/Users/saulhoward/.emacs.d/bin
export PATH=$PATH:/Users/saulhoward/.pyenv/shims/

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
export GOPRIVATE="github.com/saulhoward"

# chromium hidpi fix
# alias chromium='chromium --force-device-scale-factor=1.25'
export PATH="/usr/local/opt/tcl-tk/bin:$PATH"

DISABLE_AUTO_TITLE="true"
function precmd () {
  window_title="\033]0;${PWD##*/}\007"
  echo -ne "$window_title"
}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/saulhoward/bin/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/saulhoward/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/saulhoward/bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/saulhoward/bin/google-cloud-sdk/completion.zsh.inc'; fi

# ANTLR
export CLASSPATH=".:/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH"
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'

. /Users/saulhoward/src/rupa/z/z.sh

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

source <(plz --completion_script)
# alias dd='cd /Users/saulhoward/src/saulhoward/deepdrama'

source "$HOME/.secretrc"
