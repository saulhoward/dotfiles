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

4. Set up the git filter that keeps private Zed settings out of the repo (see below):

   ```sh
   git config filter.zed-private.clean 'scripts/zed-settings-filter clean'
   git config filter.zed-private.smudge 'scripts/zed-settings-filter smudge'
   git config filter.zed-private.required true
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

Then set the plugin's "Vimrc file name" to `.local/.obsidian.vimrc`. Obsidian only understands
plain `map`/`set` lines, so keep `prose.vimrc` to those.

## Day to day

- **Update all tools:** `nix flake update --flake ~/dotfiles/nix && nix profile upgrade --all`,
  then commit `nix/flake.lock`.
- **Add a tool:** add it to the list in `nix/flake.nix`, then run `nix profile upgrade --all`.
- **Per-project tools:** put `use flake` in a project's `.envrc` and give the project a `flake.nix` with a dev shell.
- **Global npm packages** install to `~/.local/share/npm`, because the Nix store is read-only.
- **nvim plugins** use the built-in `vim.pack` and are pinned in `nvim/.config/nvim/nvim-pack-lock.json`.
  Run `:lua vim.pack.update()` to update them.
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

### Pi settings

Only `~/.pi/agent/settings.json` is synced. Before the first `stow --no-folding pi`,
back up any existing settings file outside the repo and move it out of the way.
`--no-folding` keeps Pi's directories local and links only the settings file.

Git ignores everything else under the `pi/` package by default. Keep authentication,
MCP configuration, sessions, plugin state, installs, and caches local; do not copy
`~/.pi` wholesale into this public repo. New machines need their own provider and
plugin logins.

Pi writes preference and package changes back to the linked settings file. Review
its diff before committing: the current file has no credentials, but ignore rules
do not protect against secrets added to an allowed file.

On macOS, Homebrew is only used for GUI apps that Nix doesn't package well.
