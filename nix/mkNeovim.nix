# Function for creating a Neovim derivation
{
  git,
  sqlite,
  lib,
  stdenv,
  neovim-unwrapped,
  neovimUtils,
  wrapNeovimUnstable,
}:
with lib; with lib.strings;
  {
    # The most used args
    #
    plugins ? [],
    extraPackages ? [],
    # When true, then nvim reads the config from ~/.config/nvim
    # When false, then nvim reads the config from the nix store
    outOfStoreConfig ? null, 
    immutableConfig ? null,

    # Extra args, which are not defined in `wrapNeovimUnstable`
    #
    # NVIM_APPNAME -- `:help $NVIM_APPNAME`
    # This will also rename the binary.
    appName ? "nvim",
    aliases ? [],
    withSqlite ? false, # Add sqlite? This is a dependency for some plugins

    # Args inherited from `wrapNeovimUnstable`
    # They can typically be left as their defaults
    #

    # Additional lua packages (not plugins), e.g. from luarocks.org.
    # e.g. p: [p.jsregexp]
    extraLuaPackages ? p: [],
    extraPython3Packages ? p: [], # Additional python 3 packages
    withPython3 ? false, # Build Neovim with Python 3 support?
    withRuby ? false, # Build Neovim with Ruby support?
    withNodeJs ? false, # Build Neovim with NodeJS support?
    autoconfigure ? false, # Include `plugin.passthru.initLua` to the config?
  }:

  assert (isNull immutableConfig || isNull outOfStoreConfig)
         && !(!(isNull immutableConfig) && !(isNull outOfStoreConfig))
  || throw "Either configPath or outOfStoreConfig must be passed. Exactly one of them";

  assert (isNull immutableConfig || isPath immutableConfig)
  || throw "configPath must be a path. Or not passed at all";

  assert (isNull outOfStoreConfig || isString outOfStoreConfig)
  || throw "outOfStoreConfig must be a string. Or not passed at all";

	let
    externalPackages = extraPackages ++ (lib.optionals withSqlite [sqlite]);

      nvimConfig =
      if isPath immutableConfig
      then immutableConfig
      else runCommandLocal "kickstart-config-symlink" {}
                           ''ln -s ${lib.escapeShellArg outOfStoreConfig} $out'';


initLua = ''
  -- Clean up runtime paths
  function cleanupRuntime()
    local vimPackDir = 'vim[-]pack[-]dir'
    local neovimRuntime = 'neovim[-]unwrapped'

    local packpath = vim.opt.packpath:get()
    local rtp = vim.opt.rtp:get()

    vim.opt.packpath = {}
    vim.opt.rtp = {}

    for _, v in pairs(packpath) do
      if string.match(v, vimPackDir) or string.match(v, neovimRuntime) then
        vim.opt.packpath:append(v)
      end
    end

    for _, v in pairs(rtp) do
      if string.match(v, vimPackDir) or string.match(v, neovimRuntime) then
        vim.opt.rtp:append(v)
      end
    end
  end
  cleanupRuntime()
 --Only try to load user config if it exists
  local config_path = "${nvimConfig}"
    if vim.fn.isdirectory(config_path) == 1 then
      vim.opt.rtp:prepend(config_path)
      vim.opt.rtp:append(config_path .. "/after")
      
      local init_file = config_path .. "/init.lua"
      if vim.fn.filereadable(init_file) == 1 then
        dofile(init_file)
      else
        -- Look for init.vim as fallback
        local init_vim = config_path .. "/init.vim"
        if vim.fn.filereadable(init_vim) == 1 then
          vim.cmd("source " .. init_vim)
        end
      end
    end
      '';
    # Add arguments to the Neovim wrapper script
    extraMakeWrapperArgs = builtins.concatStringsSep " " (
      # Set the NVIM_APPNAME environment variable
      (optional (appName != "nvim")
        ''--set NVIM_APPNAME "${appName}"'')
      # Add external packages to the PATH
      ++ (optional (externalPackages != [])
        ''--prefix PATH : "${makeBinPath externalPackages}"'')
      # Set the LIBSQLITE_CLIB_PATH if sqlite is enabled
      ++ (optional withSqlite
        ''--set LIBSQLITE_CLIB_PATH "${sqlite.out}/lib/libsqlite3.so"'')
      # Set the LIBSQLITE environment variable if sqlite is enabled
      ++ (optional withSqlite
        ''--set LIBSQLITE "${sqlite.out}/lib/libsqlite3.so"'')
    );

    # Prepare to wrap `neovim-unwrapped`
    neovimConfig = neovimUtils.makeNeovimConfig {
      inherit plugins
              extraLuaPackages
              extraPython3Packages withPython3 withRuby withNodeJs;
      customLuaRC = initLua; wrapRc = true;
    };

    neovimConfig' = neovimConfig // {
      wrapperArgs = lib.escapeShellArgs neovimConfig.wrapperArgs + " " + extraMakeWrapperArgs;};

    # Make a neovim derivation
    neovim = wrapNeovimUnstable neovim-unwrapped neovimConfig';

  in
    neovim.overrideAttrs (oa: {
      meta.mainProgram = appName;
      buildPhase =
        oa.buildPhase
        # Rename `nvim` binary to $NVIM_APPNAME
        + lib.optionalString (appName != "nvim") ''
          mv $out/bin/nvim $out/bin/${lib.escapeShellArg appName}
        '' +
        # Add aliases
        (let
          orig = "$out/bin/${lib.escapeShellArg appName}";
          alias = (x: "$out/bin/${lib.escapeShellArg x}");
          cmds = map (x: "ln -s ${orig} ${alias x}") aliases;
        in (concatStringsSep ";\n" cmds));
    })
