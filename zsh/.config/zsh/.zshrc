# colors
autoload -U colors && colors
autoload -Uz vcs_info
precmd () { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' %b'
setopt PROMPT_SUBST
function () {
  local prompt_base='%b%{$fg[yellow]%}%c%{$fg[white]%}${vcs_info_msg_0_} %B%{$fg[green]%}$%b '
  if [[ ${SSH_TTY} ]] ; then
      PROMPT='%B%{$fg[magenta]%}%n@%m '$prompt_base
  else
      PROMPT=$prompt_base
  fi
}

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

bindkey -v
export KEYTIMEOUT=1
bindkey '^R' history-incremental-search-backward

bindkey '^H' backward-kill-word
bindkey '^l' autosuggest-accept

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

#confirm before doing something bad
alias cp='cp -i'                          # confirm before overwriting something
alias rm='rm -i'
alias mv='mv -i'

alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more='less'
alias q='exit'
alias c='clear'
alias h='history'
alias cs='clear;ls'
if [[ $(uname) == "Darwin" ]]; then
    alias ls='gls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
    alias ll='gls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
else
    alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
    alias ll='ls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
fi
alias l='ls -l'
alias la='ls -la'
alias grep='grep --color=auto'
alias home='cd ~'
alias root='cd /'
alias ..='cd ..'
alias ...='cd ..; cd ..'
alias ....='cd ..; cd ..; cd ..'

# git
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias stat='git status'  # 'status' is protected name so using 'stat' instead
alias tag='git tag'
alias newtag='git tag -a'

alias vim='nvim'
export EDITOR='nvim'
export VISUAL='nvim'

# for cp
ulimit -s unlimited

# homebrew
export PATH="/opt/homebrew/bin:$PATH"    # if `pyenv` is not already on PATH

# fuck
eval $(thefuck --alias)

# fzf
# tokyonight dark
export FZF_DEFAULT_OPTS='--color=bg+:#292e42,bg:#16161e,border:#1f2335,hl:#ff9e64,fg:#a9b1d6,header:#292e42,pointer:#bb9af7,fg+:#a9b1d6,preview-bg:#24283b,prompt:#7dcfff,hl+:#7aa2f7,info:#e0af68'
# tokyonight day
# export FZF_DEFAULT_OPTS='--color=bg+:#c4c8da,bg:#e9e9ec,border:#e9e9ec,hl:#b15c00,fg:#6172b0,header:#c4c8da,pointer:#9854f1,fg+:#6172b0,preview-bg:#e1e2e7,prompt:#007197,hl+:#2e7de9,info:#8c6c3e'

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
export GOPRIVATE="github.com/saulhoward/*,github.com/deepdrama/*"

# # ANTLR
# export CLASSPATH=".:/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH"
# alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
# alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'

# please
export PATH="${HOME}/.please/bin:${PATH}"
source <(plz --completion_script)

# GCP
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/src/deepdrama/ddsecrets/gcp-service-account.json"

# npm
# RUN THIS: npm config set prefix ~/.npm
export NPM_HOME="${HOME}/.npm"
export PATH="$PATH:$HOME/.npm/bin"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ $(uname) == "Darwin" ]]; then
    source "$HOME/.config/zsh/macos.zsh"
else
    export PATH="$PATH:/opt/nvim-linux64/bin"
fi

# dotnet
export DOTNET_ROOT=$HOME/usr/local/share/dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

