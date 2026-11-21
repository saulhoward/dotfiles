# Git discovers git-cleanup on PATH; no global Git alias or config rewrite needed.
path=("$ZDOTDIR/bin" $path)

# Adapted from jessfraz/global-nix's home/programs/bash.nix (see bin/UPSTREAM.md).
# Only change directory after a completed receipt confirms worktree removal.
gcleanup() {
    local receipt primary argument
    for argument in "$@"; do
        case "$argument" in
            # Git intercepts --help to look for a manpage; -h reaches the script.
            -h|--help) command git cleanup -h; return $? ;;
        esac
    done
    receipt=$(command git cleanup --json "$@") || return $?
    printf '%s' "$receipt" | command python3 -c 'import json,sys; result=json.load(sys.stdin); print(result.get("summary", json.dumps(result, indent=2)))' || return $?
    primary=$(printf '%s' "$receipt" | command python3 -c 'import json,sys; result=json.load(sys.stdin); print(result["primary_worktree"] if result.get("status") == "completed" and result.get("worktree_removed") else "")') || return $?
    if [[ -n $primary ]]; then
        builtin cd -- "$primary" || return $?
    fi
}
