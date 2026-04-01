vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }

require('catppuccin').setup {
  float = { transparent = false, solid = false },
  flavour = 'mocha', -- latte, frappe, macchiato, mocha
  background = { -- :h background
    light = 'latte',
    dark = 'mocha',
  },
  auto_integrations = false,
  default_integrations = true,
  lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
    inlay_hints = {
      background = false,
    },
  },
}

vim.o.background = 'dark'
vim.cmd.colorscheme 'catppuccin'
