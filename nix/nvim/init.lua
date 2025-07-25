vim.loader.enable()
require("keymaps")
require("options")
require("quickswap")
require("lsp")

require("lze").load {
  { "nvim-surround",
    event = "BufReadPost",
    after = function()
      require("nvim-surround").setup()
    end,
  },
  { "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup()
    end,
  },
}
vim.lsp.enable({ "gopls", "nil", "luals", "clangd", "ocaml" })
vim.lsp.config("*", { root_markers = { ".git" }, })
