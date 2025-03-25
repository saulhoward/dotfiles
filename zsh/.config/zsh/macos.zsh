alias deleteDS_Store="find . -name .DS_Store -delete"

## brew stuff
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH:~/.scripts

#syntax highlighting
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

eval "$(direnv hook zsh)"


## ant
# export PATH=$PATH:~/src/platform/bin
