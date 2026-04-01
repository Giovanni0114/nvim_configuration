vim.pack.add {
    { src = 'https://github.com/FabijanZulj/blame.nvim' },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
    { src = 'https://github.com/sindrets/diffview.nvim' },
}

require("blame").setup()
require("gitsigns").setup()
require("diffview").setup()
