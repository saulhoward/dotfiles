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

# path
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/bin:${PATH}"

# macos
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"

# colours
autoload -U colors && colors
PROMPT="%{$fg[green]%}%n@%m %{$fg[yellow]%}>> %{$reset_color%}"
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
alias vim=lvim

# ls alias
alias ls='gls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
alias ll='gls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# go
export GOROOT="$(brew --prefix golang)/libexec"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
export GOPRIVATE="github.com/saulhoward/*,github.com/endx-gg/*"

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

# poetry (python build tool)
export PATH="$HOME/.poetry/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# kubectl
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# tmux
alias ta='tmux new-session -A -s'

# emacs
export PATH="$PATH:${HOME}/.config/emacs/bin"
