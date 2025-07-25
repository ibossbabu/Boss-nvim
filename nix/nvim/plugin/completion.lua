require("luasnip.loaders.from_snipmate").lazy_load({ path = "./snippets" })
require("blink-cmp").setup({
  keymap = {
    preset = 'default',
    ["<C-e>"] = { "show", "show_documentation", "hide_documentation" },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  snippets = {
    preset = "luasnip",
  },
})
