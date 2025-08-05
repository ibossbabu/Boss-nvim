{
  description = "Sakhollow Neovim-Custom Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    flake-utils,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    neovim-overlay = import ./nix/neovim-overlay.nix {inherit inputs;};
  in
    flake-utils.lib.eachSystem supportedSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [neovim-overlay];
        };

        tmuxModule = import ./nix/tmux.nix {
          inherit inputs pkgs;
        };

        shell = pkgs.mkShellNoCC {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            nvim-on-nix-sealed
          ];
          shellHook = ''
            echo "Neovim is ready: $(nvim --version && which nvim)"
          '';
        };
      in {
        packages = rec {
          default = nvim;
          nvim = pkgs.nvim-on-nix-sealed;
          tmux = tmuxModule.package;
        };
        devShells.default = shell;
        apps = {
          default = {
            type = "app";
            program = "${pkgs.nvim-on-nix-sealed}/bin/nvim";
          };
          nvim = {
            type = "app";
            program = "${pkgs.nvim-on-nix-sealed}/bin/nvim";
          };
          tmux = tmuxModule.app;
        };
      }
    );
}
