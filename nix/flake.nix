# Command-line tools for every machine, installed as one package into the nix profile.
#   first time:  nix profile add ~/dotfiles/nix
#   update all:  nix flake update --flake ~/dotfiles/nix && nix profile upgrade --all
#   add a tool:  add it to the list below, then `nix profile upgrade --all`
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAll (pkgs: {
        default = pkgs.buildEnv {
          name = "dotfiles-tools";
          paths = with pkgs; [
            # shell
            direnv
            nix-direnv
            stow
            tmux
            zsh-autosuggestions
            zsh-syntax-highlighting

            # editor
            neovim
            tree-sitter

            # language servers (enabled in nvim/init.lua)
            gopls
            pyright
            typescript-language-server
            zls

            # git
            difftastic
            lazygit
            mergiraf

            # utils
            tree
            wget

            # languages (per-project versions: `use flake` in .envrc)
            go
            nodejs
            uv
            zig
          ]
          # GNU coreutils as g-prefixed commands (gls etc.), leaving macOS's BSD ones alone
          ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isDarwin coreutils-prefixed;
        };
      });
    };
}
