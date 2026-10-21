# Load plugins from whichever package manager installed them.
# zsh-syntax-highlighting must be sourced last.
function () {
  local plugin dir
  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    for dir in \
        $HOMEBREW_PREFIX/share/$plugin \
        $HOME/.nix-profile/share/$plugin \
        /run/current-system/sw/share/$plugin \
        /usr/share/zsh/plugins/$plugin \
        /usr/share/$plugin; do
      if [[ -r $dir/$plugin.zsh ]]; then
        source "$dir/$plugin.zsh"
        break
      fi
    done
  done
}
