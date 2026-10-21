setopt AUTO_CD               # type a directory name to cd into it
setopt INTERACTIVE_COMMENTS  # allow # comments on the command line

# History
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY       # save timestamps
setopt SHARE_HISTORY          # share history between sessions as commands run
setopt HIST_IGNORE_DUPS       # don't record a command repeated back-to-back
setopt HIST_IGNORE_SPACE      # don't record commands starting with a space
setopt HIST_EXPIRE_DUPS_FIRST # trim duplicates first when history is full
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # show !! expansions before running them
