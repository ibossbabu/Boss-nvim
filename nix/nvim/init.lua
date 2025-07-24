vim.loader.enable()
require("keymaps")
require("options")
require("quickswap")
require("lsp")

require('nvim-treesitter.configs').setup {
  modules = {}, ignore_install = {}, ensure_installed = '', sync_install = false, auto_install = false,
  highlight = { enable = true, },
  indent = { enable = true, },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}


require("lze").load {
  { "oil.nvim",
    keys = {
      { "-",         "<CMD>Oil<CR>",                               desc = "Open parent directory" },
      { "<leader>-", function() require("oil").toggle_float() end, desc = "Toggle Oil float" },
    },
    after = function()
      require("oil").setup({
        default_file_explorer = true,
        keymaps = {
          ["g?"] = { "actions.show_help", mode = "n" },
        },
        float = {
          padding = 4,
          max_width = 110,
          max_height = 40,
          border = "rounded",
          get_win_title = nil,
          preview_split = "auto",
          override = function(conf)
            return conf
          end,
        },
      })
    end,
  },
  {
    "luasnip", after = function() require("luasnip.loaders.from_snipmate").lazy_load({ path = "./snippets" }) end,
  },
  { "blink.cmp",
    lazy = false,
    after = function()
      require("blink.cmp").setup({
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
    end,
  },
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
  { "fzf-lua",
    keys = {
      { "<leader>sc", function() require("fzf-lua").commands() end,                desc = "search commands" },
      { "<leader>sf", function() require("fzf-lua").files() end,                   desc = "search files" },
      { "<leader>sk", function() require("fzf-lua").keymaps() end,                 desc = "search keymaps" },
      { "<leader>sg", function() require("fzf-lua").lgrep_curbuf() end,            desc = "search grep current buff" },
      { "<leader>sr", function() require("fzf-lua").resume() end,                  desc = "resume fzf" },
      { "<leader>so", function() require("fzf-lua").oldfiles() end,                desc = "search oldfiles" },
      { '<leader>sn', function() require("fzf-lua").files({ cwd = "./nvim" }) end, desc = "nvim config" },
    },
  },
  { "poimandres.nvim",
    colorscheme = "poimandres",
  },
  {
    "conform.nvim",
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          nix = { "alejandra" },
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
    end,
  },
}
vim.lsp.enable({ "gopls", "nil", "luals", "clangd" })
vim.lsp.config("*", { root_markers = { ".git" }, })
vim.cmd('colorscheme poimandres')
