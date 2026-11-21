# Dotfiles

Config for macOS and Linux. Command-line tools are installed with [Nix](https://nixos.org),
and config is symlinked into `~` with [GNU Stow](https://www.gnu.org/software/stow/).

| Package   | What                                                              |
|-----------|-------------------------------------------------------------------|
| `zsh`     | zsh config (`~/.zshenv`, `~/.config/zsh`)                         |
| `vim`     | `~/.vimrc`: plain, plugin-free settings shared by vim and nvim    |
| `nvim`    | sources `~/.vimrc`, adds the vesper theme and treesitter          |
| `direnv`  | direnv with nix-direnv (`use flake` in `.envrc`)                  |
| `ghostty` | Ghostty terminal config                                           |
| `zed`     | Zed editor config                                                 |
| `codex`   | Codex global instructions (`~/.codex/AGENTS.md`)                  |
| `pi`      | Pi preferences and package list (`~/.pi/agent/settings.json`)    |
| `nix/`    | not a stow package: the flake listing every tool to install       |
| `obsidian/` | not a stow package: Obsidian's vimrc, symlinked into the vault  |

## Setup

1. Install Nix, e.g. with the [Determinate installer](https://determinate.systems/nix-installer/):

   ```sh
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

   The upstream installer works too, but you'll need to enable the `nix-command` and `flakes`
   experimental features.

2. Clone this repo and install the tools:

   ```sh
   git clone git@github.com:saulhoward/dotfiles.git ~/dotfiles
   nix profile add ~/dotfiles/nix
   ```

3. In a new shell, link the config. Stow won't overwrite existing files, so move any old
   `~/.zshrc`, `~/.vimrc` and so on out of the way first:

   ```sh
   cd ~/dotfiles
   stow zsh vim nvim direnv ghostty zed codex
   stow --no-folding pi
   ```

4. Set up the Git filters that keep private Zed and Pi settings out of the repo
   before staging settings changes (see below):

   ```sh
   git config filter.zed-private.clean 'scripts/zed-settings-filter clean'
   git config filter.zed-private.smudge 'scripts/zed-settings-filter smudge'
   git config filter.zed-private.required true
   git config filter.pi-private.clean 'scripts/pi-settings-filter clean'
   git config filter.pi-private.smudge 'scripts/pi-settings-filter smudge'
   git config filter.pi-private.required true
   ```

5. Open a new shell. nvim installs its plugins the first time it starts.

Over ssh on a machine you don't want to set up, copying `~/.vimrc` on its own is enough
(add `~/.vim/prose.vimrc` for the markdown wrapping settings).

### Obsidian

Obsidian's vim mode ([vimrc support plugin](https://github.com/esm7/obsidian-vimrc-support))
can only read files inside the vault, so link the vimrc and the prose settings it shares with
vim into the vault's `.local` folder, which isn't synced:

```sh
ln -s ~/dotfiles/obsidian/.obsidian.vimrc ~/sync/orac/.local/.obsidian.vimrc
ln -s ~/dotfiles/vim/.vim/prose.vimrc ~/sync/orac/.local/prose.vimrc
```

Then set the plugin's "Vimrc file name" to `.local/.obsidian.vimrc` and enable
"Support JavaScript commands" in Vimrc Support. The `O` mapping uses a JavaScript command
to continue `- ` bullet lists above the current line, preserving indentation (including
at the start of a note or after a blank line). Other lines use Editor Shortcuts as before.
Obsidian only understands plain `map`/`set` lines in the shared prose settings, so keep
`prose.vimrc` to those.

## Day to day

- **Update all tools:** `nix flake update --flake ~/dotfiles/nix && nix profile upgrade --all`,
  then commit `nix/flake.lock`.
- **Add a tool:** add it to the list in `nix/flake.nix`, then run `nix profile upgrade --all`.
- **Per-project tools:** put `use flake` in a project's `.envrc` and give the project a `flake.nix` with a dev shell.
- **Global npm packages** install to `~/.local/share/npm`, because the Nix store is read-only.
- **nvim plugins** use the built-in `vim.pack` and are pinned in `nvim/.config/nvim/nvim-pack-lock.json`.
  Run `:lua vim.pack.update()` to update them.
- **Branch changes in nvim:** `:GitBranchChanges` opens Gitsigns' changed-file tree
  against `master`, with an editable file pane alongside it. Use `:GitBranchChanges main`
  (or another ref) to override the base. Includes committed and saved local changes.
  Press `<Enter>` on a file to open it, `]f` / `[f` for the next / previous file,
  and `g?` in the panel for help. Opens in a new tab unless starting from an empty
  window; close the review tab with `:tabclose`. The file tree never wraps, including
  after refreshes. Reviewed files show gutter signs against the selected base;
  the global Gitsigns default and quickfix are unchanged. Comparisons are buffer-local,
  so signs also change in any other window showing the same file, and remain after
  closing the review. Lualine shows an orange `diff:<base>` label (e.g. `diff:master`)
  whenever that buffer compares against a non-default base. Use `:Gitsigns reset_base`
  in a file to return to index comparisons and hide the label. The default is staged
  content (the index), not `HEAD`; unrelated newly opened files need no reset.
  For side-by-side diffs instead, use `:Gitsigns diff master`.
- **Machine-specific shell config** (work settings, credentials, private paths) goes in
  `~/.config/zsh/local.zsh`, which git ignores. See `local.zsh.example`. **This repo is public.**
- **Private Zed settings:** the top-level `agent`, `agent_servers`, `language_models` and
  `context_servers` keys in Zed's `settings.json` are never committed. A git filter
  (`scripts/zed-settings-filter`) strips them when you commit, saves them to
  `~/.config/zed/settings.private.jsonc`, and puts them back on checkout. Edit settings in Zed as
  usual. Add more keys to `PRIVATE_KEYS` in the script.

### Git worktrees

The zsh functions in `zsh/.config/zsh/worktrees.zsh` use sibling worktrees backed
by a hidden bare repo:

```text
my-project/
├── .git/           # bare repo
├── main/           # remote's default branch (may have another name)
└── feature-login/  # branch feature/login
```

| Command | Behavior |
|---------|----------|
| `gclone <url> [directory]` | Set up this layout and enter the default-branch worktree |
| `gwt` | List worktrees |
| `gwtnew <branch> [base]` | Create a branch and worktree, then enter it; base defaults to `origin/HEAD` |
| `gwtadd <branch>` | Check out an existing local branch, or create a tracking branch from `origin/<branch>` |
| `gwtcd [branch]` | Enter a branch's worktree; no argument opens an fzf picker |
| `gwtrex [branch]` | Switch to a worktree's Rex session, creating it if needed; no argument opens an fzf picker |
| `gwtrexadd <branch>` | Like `gwtadd`, then create or switch to the worktree's Rex session |
| `gwtrexnew <branch> [base]` | Like `gwtnew`, then create or switch to the worktree's Rex session |
| `gwtrm [branch]` | Remove a worktree, keeping its branch; no argument removes the current worktree |
| `gwtprune` | Prune stale worktree metadata |

```sh
gclone git@github.com:org/my-project.git
git fetch origin
gwtnew feature/login
gwtrex feature/login
gwtcd main
gwtrm feature/login
```

Commands work from the parent directory or anywhere inside its worktrees. Branch
slashes become hyphens in directory names; existing paths are never reused.
Only cloning fetches automatically: run `git fetch origin` before `gwtnew` or
`gwtadd` when you want fresh remote state. New feature branches do not track the
base branch. `gwtrm` never forces removal or deletes branches; on failure it
restores your previous directory. Existing ordinary checkouts are not converted.
`gwtrex` requires the `rex` CLI on PATH. It reuses the session labelled
`gwt:<project>:<worktree-directory>`, or creates one in the worktree directory, then
selects it in the Rex app without changing your current shell's directory. Duplicate
matching labels are rejected. Rex uses `REX_CLIENT` to target your current client;
when outside Rex, it can automatically select the sole connected app client. Set
`REX_CLIENT` explicitly if multiple app clients are connected.

`gwtrexadd` and `gwtrexnew` create worktrees like `gwtadd` and `gwtnew`, but leave
your current shell's directory unchanged. For example, `gwtrexnew feature/login`
creates the branch and worktree, then selects its Rex session. If the Git step
fails, Rex is not invoked. If Rex fails, the new worktree and branch are kept;
retry with `gwtrex <branch>` after fixing the Rex connection. Your shell stays in
its original directory in either case.

An empty remote cannot supply an initial worktree; a failed clone/setup leaves
its directory in place for inspection.

Run the local integration tests with `zsh -f scripts/test-worktrees.zsh`.

### Git cleanup

`git cleanup` and `gcleanup` are adapted from
[jessfraz/global-nix](https://github.com/jessfraz/global-nix), with the build-output
policy from [jessfraz/dotfiles](https://github.com/jessfraz/dotfiles). Pinned sources
and local adaptations are recorded in `zsh/.config/zsh/bin/UPSTREAM.md`.

**Cleanup acts immediately by default.** It fetches the remote base, fast-forwards
its local branch, then deletes the current clean, merged feature branch and its
linked worktree, if any. It never deletes the primary clone, selected base
worktree, shared Git database or a remote branch. On the base branch it only
updates the base and runs Git maintenance. `gcleanup` also returns the shell to
the primary clone (or the base worktree in a `gwt*` layout) after removal.

Preview first; a plan fetches the base but does not delete files or branches:

```sh
git cleanup --plan
# Save outside the worktree being removed, then review before executing:
git cleanup --plan > /tmp/git-cleanup-plan.json
gcleanup --execute /tmp/git-cleanup-plan.json
```

Dirty, locked or unmerged worktrees are refused. Recognized ignored build output
can be removed with a linked worktree; other ignored files block its removal.
Busy build caches are skipped. Submodule Git storage is retained in the common
Git directory under `cleanup-submodules/`. `--force` waives only the merge check,
not local-file protections. `--no-gc` skips Git garbage collection; `--base` and
`--remote` override the default base and `origin`.

Both ordinary clones and the bare-primary layout created by `gclone` / `gwt*`
are supported. In a `gwt*` layout, cleanup finds the selected base's worktree in
Git's registry, even if its directory was renamed. That worktree must exist;
cleanup refuses to remove anything if it is missing or ambiguous. From the
project parent, cleanup only updates the base. A dirty base is left untouched
when removing a merged feature. Unlike `gwtrm`, cleanup also deletes the finished
local branch after verifying it is merged.

The commands use existing Git/SSH and `gh` authentication, with no credential wrapper.
Python 3.10+, Git, `gh` (for GitHub merge evidence) and `lsof` (for build-cache
checks) must be on PATH; Python and `lsof` are included in the Nix tools.

After stowing `zsh`, open a new shell, or load just these commands in an existing
one with `source "$ZDOTDIR/cleanup.zsh"`. No cleanup runs on shell startup.
Run the isolated tests with
`python3 -m unittest discover -s tests -p 'test_git_cleanup*.py'`.

### Pi settings

Only `~/.pi/agent/settings.json` is synced. Before the first `stow --no-folding pi`,
back up any existing settings file outside the repo and move it out of the way.
`--no-folding` keeps Pi's directories local and links only the settings file.

Git ignores everything else under the `pi/` package by default. Keep authentication,
MCP configuration, sessions, plugin state, installs, and caches local; do not copy
`~/.pi` wholesale into this public repo. New machines need their own provider and
plugin logins.

Pi writes preference and package changes back to the linked settings file. The
Git clean/smudge mask in `scripts/pi-settings-filter` commits only the reviewed
`PUBLIC_KEYS` allowlist. Other top-level settings, including the entire
`slack-bridge` configuration, are saved locally to
`~/.pi/agent/settings.private.json` with owner-only permissions and restored on
checkout. Saved private values take precedence over any old tracked private
blocks. The working settings retain their private values; they are absent from
the committed blob. This is a Git filter, not a native Pi settings feature.

Configure the required filter on every clone before staging settings. New keys
stay private until reviewed and added to the allowlist. Review values within
allowed fields too, especially package URLs; an allowed key is not proof that
its contents are safe. Keep the private file local and back it up securely.
Run the mask tests with `python3 -m unittest discover -s tests -p 'test_pi_settings_filter.py'`.

On macOS, Homebrew is only used for GUI apps that Nix doesn't package well.
