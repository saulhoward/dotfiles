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

# Stub Rex: verify its arguments without opening real sessions during tests.
command mkdir "$tmp/bin"
command cat > "$tmp/bin/rex" <<'SH'
#!/bin/sh
if [ "$1" = do ] && [ "$2" = -e ]; then
    printf '%s' "$3" > "$REX_TEST_LOG.lua"
    shift 3
    printf '%s\n' "$@" > "$REX_TEST_LOG"
    [ "${REX_TEST_EXIT:-0}" = 0 ] || exit "$REX_TEST_EXIT"
    printf '%s\n' '"session:test-id"'
else
    printf '%s\n' "$@" > "$REX_TEST_LOG.select"
    exit "${REX_TEST_SELECT_EXIT:-0}"
fi
SH
command chmod +x "$tmp/bin/rex"
export PATH="$tmp/bin:$PATH" REX_TEST_LOG="$tmp/rex-args"
original=$PWD
gwtrex feature/login
[[ $PWD == "$original" ]]
args=("${(@f)$(<"$REX_TEST_LOG")}")
[[ ${#args} == 3 && $args[1] == 'label=gwt:project with spaces:feature-login' ]]
[[ $args[2] == "cwd=$root/feature-login" && $args[3] == --json ]]
select_args=("${(@f)$(<"$REX_TEST_LOG.select")}")
[[ ${#select_args} == 3 && $select_args[1] == do && $select_args[2] == session.select ]]
[[ $select_args[3] == session_id=session:test-id ]]
if (( $+commands[fzf] )); then
    FZF_DEFAULT_OPTS='--filter=feature/login' gwtrex
    [[ $PWD == "$original" ]]
    args=("${(@f)$(<"$REX_TEST_LOG")}")
    [[ $args[2] == "cwd=$root/feature-login" ]]
fi
command rm "$REX_TEST_LOG" "$REX_TEST_LOG.select"
if gwtrex nonexistent; then
    print -u2 'missing Rex worktree was accepted'; exit 1
fi
[[ ! -e $REX_TEST_LOG && $PWD == "$original" ]]
if REX_TEST_EXIT=7 gwtrex feature/login; then
    print -u2 'Rex failure was not propagated'; exit 1
fi
[[ $PWD == "$original" && ! -e "$REX_TEST_LOG.select" ]]
if REX_TEST_SELECT_EXIT=8 gwtrex feature/login; then
    print -u2 'Rex selection failure was not propagated'; exit 1
fi
[[ $PWD == "$original" ]]

# Combined commands preserve the caller's directory and target the new worktree.
original=$PWD
assert_rex_target() {
    local target=$1
    local -a args select_args
    [[ $PWD == "$original" ]]
    args=("${(@f)$(<"$REX_TEST_LOG")}")
    [[ $args[1] == "label=gwt:project with spaces:${target:t}" ]]
    [[ $args[2] == "cwd=$target" ]]
    select_args=("${(@f)$(<"$REX_TEST_LOG.select")}")
    [[ $select_args[1] == do && $select_args[2] == session.select ]]
    [[ $select_args[3] == session_id=session:test-id ]]
}

gwtrexnew rex/default
assert_rex_target "$root/rex-default"
[[ $(command git -C "$root/rex-default" rev-parse HEAD) == $(command git rev-parse origin/trunk) ]]
gwtrexnew rex/explicit trunk
assert_rex_target "$root/rex-explicit"
[[ $(command git -C "$root/rex-explicit" rev-parse HEAD) == $(command git rev-parse trunk) ]]
command git branch rex/local trunk
gwtrexadd rex/local
assert_rex_target "$root/rex-local"
command git -C "$tmp/upstream" branch rex/remote
command git fetch origin
gwtrexadd rex/remote
assert_rex_target "$root/rex-remote"
[[ $(command git -C "$root/rex-remote" rev-parse --abbrev-ref '@{upstream}') == origin/rex/remote ]]

# Worktree failures (including bad arguments) must not invoke Rex.
command rm "$REX_TEST_LOG" "$REX_TEST_LOG.select"
original=$PWD
if gwtrexadd nonexistent; then
    print -u2 'missing branch was accepted by gwtrexadd'; exit 1
fi
if gwtrexnew feature-login; then
    print -u2 'collision was accepted by gwtrexnew'; exit 1
fi
if gwtrexadd; then
    print -u2 'gwtrexadd accepted missing arguments'; exit 1
fi
if gwtrexnew; then
    print -u2 'gwtrexnew accepted missing arguments'; exit 1
fi
[[ ! -e $REX_TEST_LOG && ! -e "$REX_TEST_LOG.select" && $PWD == "$original" ]]

# Rex failures propagate, but preserve the successfully created worktree.
if REX_TEST_EXIT=7 gwtrexnew rex/failure; then
    print -u2 'gwtrexnew swallowed Rex failure'; exit 1
else
    [[ $? == 7 ]]
fi
[[ $PWD == "$original" && -f "$root/rex-failure/.git" ]]
command git branch rex/select-failure trunk
if REX_TEST_SELECT_EXIT=8 gwtrexadd rex/select-failure; then
    print -u2 'gwtrexadd swallowed Rex selection failure'; exit 1
else
    [[ $? == 8 ]]
fi
[[ $PWD == "$original" && -f "$root/rex-select-failure/.git" ]]
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
