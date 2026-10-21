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
| `nix/`    | not a stow package: the flake listing every tool to install       |

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
   stow zsh vim nvim direnv ghostty zed
   ```

4. Set up the git filter that keeps private Zed settings out of the repo (see below):

   ```sh
   git config filter.zed-private.clean 'scripts/zed-settings-filter clean'
   git config filter.zed-private.smudge 'scripts/zed-settings-filter smudge'
   git config filter.zed-private.required true
   ```

5. Open a new shell. nvim installs its plugins the first time it starts.

Over ssh on a machine you don't want to set up, copying `~/.vimrc` on its own is enough.

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

On macOS, Homebrew is only used for GUI apps that Nix doesn't package well.
