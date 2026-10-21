#confirm before doing something bad
alias cp='cp -i'                          # confirm before overwriting something
alias rm='rm -i'
alias mv='mv -i'

alias df='df -h'                          # human-readable sizes
alias more='less'
alias q='exit'
alias c='clear'
alias h='history'
alias cs='clear;ls'
# GNU ls (gls via coreutils on macOS)
if (( $+commands[gls] )); then
    alias ls='gls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
    alias ll='gls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
elif ls --version &>/dev/null; then
    alias ls='ls --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
    alias ll='ls -lh --group-directories-first --time-style=+"%d.%m.%Y %H:%M" --color=auto'
else
    alias ls='ls -G'
    alias ll='ls -lhG'
fi
alias l='ls -l'
alias la='ls -la'
alias grep='grep --color=auto'
alias home='cd ~'
alias root='cd /'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias vim='nvim'
