require('nvim-treesitter.configs').setup {
  modules = {}, ignore_install = {}, ensure_installed = '', sync_install = false, auto_install = false,
  highlight = { enable = true, },
  indent = { enable = true, }, textobjects = {
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
