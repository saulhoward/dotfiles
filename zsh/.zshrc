###
# .zshrc saulhoward.com
###

# big history
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# vi mode
bindkey -v
export KEYTIMEOUT=1
bindkey '^R' history-incremental-search-backward

# completion
zstyle :compinstall filename "${HOME}/.zshrc"
autoload -U compinit promptinit
compinit -u
promptinit

# colours
autoload -U colors && colors
PROMPT="%{$fg[red]%}%n@%m %{$fg[yellow]%}>> %{$reset_color%}"
RPROMPT=" %{$fg[blue]%}%~%{$reset_color%}"

# window title
DISABLE_AUTO_TITLE="true"
function precmd () {
  window_title="\033]0;${PWD##*/}\007"
  echo -ne "$window_title"
}

# vim / neovim
export EDITOR=vim
export VISUAL=vim
alias vim=nvim

# ls alias
alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
alias ll='ls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"    # if `pyenv` is not already on PATH
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export GOPRIVATE="github.com/saulhoward"

# ANTLR
export CLASSPATH=".:/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH"
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'

# please
export PATH="${HOME}/.please/bin:${PATH}"
source <(plz --completion_script)

# GCP
if [ -f '/Users/saul/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/saul/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/saul/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/saul/google-cloud-sdk/completion.zsh.inc'; fi

