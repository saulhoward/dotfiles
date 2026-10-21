# direnv
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# GCP
if [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# nvm (to be replaced by nix)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
