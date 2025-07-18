return {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = {
    "flake.nix",
    "flake.lock",
    ".envrc"
  },
  settings = {
    nix = {
      nixpkgs = {
        allowUnfree = true,
      },
      diagnostics = {
        enable = true,
        check = { "all" },
      },
    },
  },
}
