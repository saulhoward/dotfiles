# Login shell environment. Also sourced by .zshrc for non-login interactive
# shells (e.g. most Linux terminal emulators), so it must be safe to re-run.

typeset -U path PATH  # keep PATH entries unique

# homebrew (macOS, or linuxbrew)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

export EDITOR='nvim'
export VISUAL='nvim'

# go
export GOPATH="$HOME/go"
export GOPRIVATE="github.com/saulhoward/*"

# npm
# RUN THIS: npm config set prefix ~/.npm
export NPM_HOME="${HOME}/.npm"

path=(
    $HOME/.local/bin
    $HOME/bin
    $HOME/.cargo/bin
    $path
    $GOPATH/bin
    $HOME/.npm/bin
    /opt/nvim-linux64/bin
)
path=($^path(N-/))  # drop entries that don't exist on this machine
