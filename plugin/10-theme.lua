vim.pack.add { 
    { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
    { src = 'https://github.com/tiagovla/tokyodark.nvim', name = 'tokyodark' },
}

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

 vim.pack.add({
	{
		src = "https://github.com/rose-pine/neovim",
		name = "rose-pine",
	},
})
require("rose-pine").setup()

vim.o.background = 'dark'
vim.cmd.colorscheme 'rose-pine'
