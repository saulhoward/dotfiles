# Sibling worktrees backed by a bare repo: project/{.git,main,feature-name}.
# Helpers return values through REPLY (local in each public function).
_gwt_common() {
    REPLY=$(command git rev-parse --path-format=absolute --git-common-dir) || return
    if [[ $(command git --git-dir="$REPLY" config --bool core.bare) != true ]]; then
        print -u2 'gwt: expected a bare repository with sibling worktrees (use gclone).'
        return 1
    fi
}

_gwt_default() {
    REPLY=$(command git --git-dir="$1" symbolic-ref --quiet --short refs/remotes/origin/HEAD) || {
        print -u2 'gwt: origin/HEAD is missing; run git remote set-head origin -a, or supply a base.'
        return 1
    }
}

_gwt_path() {
    local common=$1 branch=$2
    if [[ $branch == -* ]] || ! command git check-ref-format "refs/heads/$branch"; then
        print -u2 "gwt: invalid branch name: $branch"
        return 1
    fi
    REPLY="${common:h}/${branch//\//-}"
    if [[ -e $REPLY || -L $REPLY ]]; then
        print -u2 "gwt: directory already exists: $REPLY"
        return 1
    fi
}

_gwt_find() {
    local common=$1 branch=$2 record target
    while IFS= read -r -d '' record; do
        case $record in
            'worktree '*) target=${record#worktree } ;;
            "branch refs/heads/$branch") REPLY=$target; return 0 ;;
        esac
    done < <(command git --git-dir="$common" worktree list --porcelain -z)
    print -u2 "gwt: no worktree for branch: $branch"
    return 1
}

gclone() {
    if (( $# < 1 || $# > 2 )); then
        print -u2 'usage: gclone <url> [directory]'
        return 1
    fi
    local url=$1 name=${1%/} destination branch common target
    name=${name##*/}
    name=${name##*:}
    name=${name%.git}
    destination=${2:-$name}
    # Refuse existing directories, even empty ones; never overwrite a checkout.
    command mkdir -- "$destination" || return
    destination=${destination:A}
    common=$destination/.git
    command git clone --bare -- "$url" "$common" || return
    command git --git-dir="$common" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' || return
    command git --git-dir="$common" fetch origin || return
    branch=$(command git --git-dir="$common" symbolic-ref --quiet --short HEAD) || return
    command git --git-dir="$common" show-ref --verify --quiet "refs/remotes/origin/$branch" || {
        print -u2 'gclone: no default-branch commit found (is the remote empty?).'
        return 1
    }
    command git --git-dir="$common" symbolic-ref refs/remotes/origin/HEAD "refs/remotes/origin/$branch" || return
    target="$destination/${branch//\//-}"
    command git --git-dir="$common" worktree add -- "$target" "$branch" || return
    command git --git-dir="$common" branch --set-upstream-to="origin/$branch" -- "$branch" || return
    builtin cd -- "$target"
}

gwt() { command git worktree list "$@"; }
gwtprune() { command git worktree prune "$@"; }

gwtnew() {
    if (( $# < 1 || $# > 2 )); then
        print -u2 'usage: gwtnew <branch> [base]'
        return 1
    fi
    local REPLY common target branch=$1 base=${2-}
    _gwt_common || return
    common=$REPLY
    _gwt_path "$common" "$branch" || return
    target=$REPLY
    if [[ -z $base ]]; then
        _gwt_default "$common" || return
        base=$REPLY
    fi
    # A feature branch should not accidentally track origin/main.
    command git --git-dir="$common" worktree add --no-track -b "$branch" -- "$target" "$base" || return
    builtin cd -- "$target"
}

gwtadd() {
    if (( $# != 1 )); then
        print -u2 'usage: gwtadd <branch>'
        return 1
    fi
    local REPLY common target branch=$1
    _gwt_common || return
    common=$REPLY
    _gwt_path "$common" "$branch" || return
    target=$REPLY
    if command git --git-dir="$common" show-ref --verify --quiet "refs/heads/$branch"; then
        command git --git-dir="$common" worktree add -- "$target" "$branch" || return
    elif command git --git-dir="$common" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        command git --git-dir="$common" worktree add --track -b "$branch" -- "$target" "origin/$branch" || return
    else
        print -u2 "gwtadd: no local or origin branch named $branch; fetch first if needed."
        return 1
    fi
    builtin cd -- "$target"
}

gwtcd() {
    if (( $# > 1 )); then
        print -u2 'usage: gwtcd [branch]'
        return 1
    fi
    local REPLY common target record label selection
    local -a choices
    _gwt_common || return
    common=$REPLY
    if (( $# )); then
        _gwt_find "$common" "$1" || return
        target=$REPLY
    else
        if (( ! $+commands[fzf] )); then
            print -u2 'gwtcd: install fzf or supply a branch name.'
            return 1
        fi
        while IFS= read -r -d '' record; do
            case $record in
                'worktree '*) target=${record#worktree }; label='(detached)' ;;
                'branch refs/heads/'*) label=${record#branch refs/heads/} ;;
                bare) target='' ;;
                '') [[ -n $target ]] && choices+=("$label"$'\t'"$target") ;;
            esac
        done < <(command git --git-dir="$common" worktree list --porcelain -z)
        (( ${#choices} )) || return 1
        selection=$(printf '%s\0' "${choices[@]}" | command fzf --read0 --print0 --delimiter=$'\t' --with-nth=1 --prompt='worktree> ') || return
        # Command substitution preserves the trailing NUL in zsh; strip it.
        selection=${selection%$'\0'}
        target=${selection#*$'\t'}
    fi
    builtin cd -- "$target"
}

# Run in a subshell so selecting a worktree never changes the caller's directory.
gwtrex() (
    if (( $# > 1 )); then
        print -u2 'usage: gwtrex [branch]'
        return 1
    fi
    if (( ! $+commands[rex] )); then
        print -u2 'gwtrex: rex is not installed or is not on PATH.'
        return 1
    fi
    local REPLY common session_id
    _gwt_common || return
    common=$REPLY
    gwtcd "$@" || return
    # Lua handles structured responses without requiring jq or interpolating paths
    # into code. Failed lookups must not be mistaken for a missing session.
    session_id=$(command rex do -e '
        local id
        local label = rex.args.label
        for _, session in ipairs(rex.call("session.list").sessions or {}) do
            if session.label == label then
                if id then error("Multiple Rex sessions named " .. label) end
                id = session.session_id
            end
        end
        if not id then
            id = rex.call("session.create", {
                label = label,
                initial_windows = {{layout = {block = {
                    flavor = "com.superlogical.terminal.shell",
                    options = {cwd = rex.args.cwd}
                }}}}
            }).session_id
        end
        return id
    ' "label=gwt:${common:h:t}:${PWD:t}" "cwd=$PWD" --json) || return
    # Rex prints a returned string as JSON. Session IDs contain no JSON escapes.
    session_id=${session_id#\"}
    session_id=${session_id%\"}
    if [[ $session_id != session:* || $session_id == *[[:space:]\"\\]* ]]; then
        print -u2 'gwtrex: Rex returned an invalid session ID.'
        return 1
    fi
    command rex do session.select "session_id=$session_id"
)

gwtrm() {
    if (( $# > 1 )); then
        print -u2 'usage: gwtrm [branch]'
        return 1
    fi
    local REPLY common target branch=${1-} previous=$PWD moved=0
    _gwt_common || return
    common=$REPLY
    if (( ! $# )); then
        if [[ $(command git rev-parse --is-inside-work-tree) != true ]]; then
            print -u2 'gwtrm: supply a branch when outside a worktree.'
            return 1
        fi
        target=$(command git rev-parse --show-toplevel) || return
    else
        _gwt_find "$common" "$branch" || return
        target=$REPLY
    fi
    if [[ ${PWD:A} == ${target:A} || ${PWD:A} == ${target:A}/* ]]; then
        builtin cd -- "${common:h}" || return
        moved=1
    fi
    # No --force: Git refuses dirty, untracked, or locked worktrees. Keep branch.
    if ! command git --git-dir="$common" worktree remove -- "$target"; then
        (( moved )) && builtin cd -- "$previous"
        return 1
    fi
}
