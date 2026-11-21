# Git cleanup sources

These are vendored so shell startup never downloads or updates executable code.

From [jessfraz/global-nix](https://github.com/jessfraz/global-nix) at
`05574187c1ac3356873d109beeba45c43ee731dc`:

- `scripts/git-cleanup` → `git-cleanup`. Bare-primary repositories from `gclone`
  are supported by resolving the selected base's worktree from Git's registry.
  It replaces the ordinary primary clone as the protected update/return
  destination. Missing or ambiguous base worktrees are refused. Invocations
  from the bare repository or project parent only update the base.
- `scripts/git_cleanup_github.py` → `git_cleanup_github.py`. The upstream
  `with-credentials github.personal -- gh` invocation is replaced with `gh`,
  using this machine's existing GitHub CLI authentication.
- `home/programs/bash.nix` → the `gcleanup` function in `../cleanup.zsh`, adapted
  to zsh with `command` and `builtin cd --`; help is forwarded as `-h` because
  Git intercepts `--help` for manpages. Git finds the executable on PATH rather
  than through upstream's credential-wrapped Git alias.
- `tests/test_git_cleanup*.py` → the repository's `tests/`, with import/script
  paths adjusted. Local zsh integration coverage lives alongside them.

From [jessfraz/dotfiles](https://github.com/jessfraz/dotfiles) at
`cbbbcb3ccd1bc935cfcae01143213648633a29e0`:

- `bin/build_cache_policy.py` → `build_cache_policy.py` (unchanged).
- `LICENSE` → `LICENSE.dotfiles` (MIT, Jessie Frazelle).

The unrelated `cleanup` cache/package sweep is intentionally not imported.
`tests/test_git_cleanup_gwt.py` exercises the bare layout through the real
`gclone`, `gwtnew`, `gwtadd` and `gwtrm` functions.

To update, review upstream changes at pinned revisions, retain the local
integration changes, and run the cleanup tests from the repository root:

```sh
python3 -m unittest discover -s tests -p 'test_git_cleanup*.py'
```

Tests use disposable local repositories. They do not clean existing worktrees
or contact GitHub.
