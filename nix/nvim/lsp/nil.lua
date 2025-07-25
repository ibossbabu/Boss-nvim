return {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = {
    "flake.nix",
    "flake.lock",
    ".envrc"
  },
  settings = {
    nix = {
      flake = {
        autoArchive = true,
      },
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
