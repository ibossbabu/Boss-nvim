{inputs}: final: {
  system,
  lib,
  callPackage,
  vimPlugins,
  vimUtils,
  ...
}: let
  # Use this to create a plugin from a flake input
  buildVimPlugin = src: pname:
    vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = callPackage ./mkNeovim.nix {};

  plugins = let
    # The `start` plugins are loaded on nvim startup automatically.
    # It is the default. `(start plugin)` is equivalent to `plugin`.
    start = x: {
      plugin = x;
      optional = false;
    };
    # The `opt` plugins are to be loaded with `packadd` command.
    # If you want to lazy-load a plugin, then make it `opt`.
    opt = x: {
      plugin = x;
      optional = true;
    };
    /**
    * Treesitter with all grammars can add too much to startup time.
    * That's why we pick only specific grammars.
    *
    * Sometimes you just find the plugin in the list of supported
    * languages: https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#supported-languages
    * But sometimes you need to actually list them to find the right name.
    */
    listGrammars = p: pattern: (lib.optional
      (pattern != "")
      (lib.trace (lib.filter (x: lib.isList (lib.match pattern x))
        (builtins.attrNames p))
      p.c)); # p.c is any plugin; just to not brake the flow
    treesitter =
      vimPlugins.nvim-treesitter.withPlugins
      (p:
        with p;
        /*
        To search for grammars, change "" to a regex and run the build.
        */
          (listGrammars p "")
          ++ [
            go
            lua
            nix
            ocaml
            ocaml_interface
          ]);
  in
    with vimPlugins; [
      # It's technically possible to provide lua configuration for
      # plugins here, in nix, but in this template we prefer to config plugins in
      # the actual lua files inside the `nvim` config directory.
      # There are two good reasons for this decision:
      #   1. You've got an lsp assistance
      #   2. It's possisble to apply configuration just by restarting nvim,
      #      that is without rebuilding

      # lazy-load plugins https://github.com/BirdeeHub/lze
      (start lze)
      (start blink-cmp)
      (opt nvim-surround)
      (opt nvim-autopairs)
      (opt fzf-lua)
      (opt oil-nvim)
      (opt poimandres-nvim)
      (opt luasnip)

      conform-nvim
      treesitter
      nvim-treesitter-textobjects
    ];

  extraPackages = with final; [
    # language servers
    lua-language-server
    nil
    alejandra
  ];

  immutableConfig = ./nvim;

  # A string with an absolute path to config directory, to bypass the nix store.
  # To bootstrap the symlink:
  #   1. edit `./configLink.nix`
  #   2. run `./scripts/bootstrapMutableConfig.sh`
  outOfStoreConfig = import ./configLink.nix;
in {
  # This package uses config files directly from `configPath`
  # Restart nvim to apply changes in config
  nvim-on-nix-mutable = mkNeovim {
    inherit plugins extraPackages;
    inherit outOfStoreConfig;
  };

  # This package uses the config files saved in nix store
  # Rebuild to apply changes in config: e.g. `nix run .#nvim-sealed`
  nvim-on-nix-sealed = mkNeovim {
    inherit plugins extraPackages;
    inherit immutableConfig;
    appName = "nvim";
    aliases = ["vi" "vim"];
  };
}
