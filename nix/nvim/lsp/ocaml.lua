return {
  cmd = { 'ocamllsp' },
  filetypes = { 'ocaml', 'ocaml.menhir', 'ocaml.interface', 'reason', 'dune' },
  root_markers = {
    'dune-project',
    'dune',
    '.merlin',
    'opam',
    'esy.json',
    'package.json',
    '.git'
  },
  settings = {
    ocamllsp = {
      codelens = {
        enable = true,
      },
      inlayHints = {
        enable = true,
      },
      syntaxDocumentation = {
        enable = true,
      },
    }
  },
}
