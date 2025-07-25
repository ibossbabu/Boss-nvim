vim.cmd.packadd 'conform.nvim'
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    nix = { "alejandra" },
    ocaml = { "ocamlformat" },
  },
  formatters = {
    ocamlformat = {
      command = "ocamlformat",
      prepend_args = { "--enable-outside-detected-project" },
    },
  },
  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  },
})

vim.keymap.set({ "n", "v" }, "<leader>gf", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format with conform" })

require('lze').load({
  "conform.nvim",
  event = { "BufReadPost", "BufNewFile" },
})
