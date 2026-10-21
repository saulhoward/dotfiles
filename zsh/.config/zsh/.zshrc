# PATH/env for non-login shells (login shells already sourced it)
[[ -o login ]] || source "$ZDOTDIR/.zprofile"

# Order matters: completion before tools (which register completions),
# plugins after everything that defines widgets.
for file in options prompt completion keybindings aliases tools; do
    source "$ZDOTDIR/$file.zsh"
done
case $OSTYPE in
    darwin*) source "$ZDOTDIR/macos.zsh" ;;
    linux*)  source "$ZDOTDIR/linux.zsh" ;;
esac
source "$ZDOTDIR/plugins.zsh"
[[ -r $ZDOTDIR/local.zsh ]] && source "$ZDOTDIR/local.zsh"
unset file
