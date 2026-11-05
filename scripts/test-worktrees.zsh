#!/usr/bin/env zsh
# Integration tests using only temporary local repositories (no network).
set -eu
source "${0:A:h:h}/zsh/.config/zsh/worktrees.zsh"

tmp=$(mktemp -d)
tmp=${tmp:A}
trap 'builtin cd /; command rm -rf -- "$tmp"' EXIT
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME='Worktree Test' GIT_AUTHOR_EMAIL='test@example.invalid'
export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
export GIT_TERMINAL_PROMPT=0

command git init -q -b trunk "$tmp/upstream"
command git -C "$tmp/upstream" commit -q --allow-empty -m initial
builtin cd "$tmp"
gclone "$tmp/upstream" 'project with spaces'
root="$tmp/project with spaces"
[[ $PWD == "$root/trunk" ]]
[[ $(command git rev-parse --abbrev-ref '@{upstream}') == origin/trunk ]]
[[ $(command git config --get remote.origin.fetch) == '+refs/heads/*:refs/remotes/origin/*' ]]

# Default base uses the remote-tracking branch, not unpushed local commits.
command git commit -q --allow-empty -m local-only
gwtnew feature/login
[[ $PWD == "$root/feature-login" ]]
[[ $(command git rev-parse HEAD) == $(command git rev-parse origin/trunk) ]]
if command git config --get branch.feature/login.remote; then
    print -u2 'feature branch unexpectedly has an upstream'; exit 1
fi
command mkdir nested
builtin cd nested
gwtcd trunk
[[ $PWD == "$root/trunk" ]]
if gwtnew feature-login; then
    print -u2 'directory collision was not rejected'; exit 1
fi
if gwtnew '../escape'; then
    print -u2 'invalid branch was not rejected'; exit 1
fi

command git -C "$tmp/upstream" branch remote/topic
command git fetch origin
gwtadd remote/topic
[[ $PWD == "$root/remote-topic" ]]
[[ $(command git rev-parse --abbrev-ref '@{upstream}') == origin/remote/topic ]]
gwtrm
[[ $PWD == "$root" && ! -d "$root/remote-topic" ]]
command git show-ref --verify --quiet refs/heads/remote/topic
gwtadd remote/topic
[[ $PWD == "$root/remote-topic" ]]

# A failed removal restores the original working directory.
print dirty > untracked
command mkdir nested
builtin cd nested
if gwtrm; then
    print -u2 'dirty worktree was removed'; exit 1
fi
[[ $PWD == "$root/remote-topic/nested" && -f ../untracked ]]
command rm ../untracked
gwtrm remote/topic
[[ $PWD == "$root" ]]

gwtcd feature/login
[[ $PWD == "$root/feature-login" ]]
gwtnew explicit-base trunk
[[ $(command git rev-parse HEAD) == $(command git rev-parse trunk) ]]
gwtcd trunk
if (( $+commands[fzf] )); then
    FZF_DEFAULT_OPTS='--filter=feature/login' gwtcd
    [[ $PWD == "$root/feature-login" ]]
fi
gwtcd trunk
gwtrm feature/login
[[ ! -d "$root/feature-login" ]]
command git show-ref --verify --quiet refs/heads/feature/login
gwtprune
gwt

# Existing destinations and ordinary checkouts must not be overwritten.
if gclone "$tmp/upstream" "$root"; then
    print -u2 'existing clone destination was accepted'; exit 1
fi
builtin cd "$tmp/upstream"
if gwtnew should-not-exist; then
    print -u2 'ordinary checkout was accepted'; exit 1
fi
[[ ! -e "$tmp/upstream/should-not-exist" ]]
print 'All worktree integration tests passed.'
