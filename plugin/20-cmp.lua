vim.pack.add({
    { src = 'https://github.com/rafamadriz/friendly-snippets' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
    { src = 'https://github.com/benfowler/telescope-luasnip.nvim' },
    { src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
    { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
    { src = 'https://github.com/hrsh7th/cmp-path' },
    { src = 'https://github.com/hrsh7th/cmp-buffer' },
    { src = 'https://github.com/uga-rosa/cmp-dictionary' },
    { src = 'https://github.com/hrsh7th/nvim-cmp' },
})

local cmp = require 'cmp'
local luasnip = require 'luasnip'
luasnip.config.setup {}

require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    completion = { completeopt = 'menu,menuone,noinsert,noselect' },

    mapping = cmp.mapping.preset.insert {
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<Enter>'] = cmp.mapping.confirm {},
        ['<C-Space>'] = cmp.mapping.complete {},
    },

    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
        { name = 'render-markdown' },
        {
            name = "dictionary",
            keyword_length = 4,
        },
    },
}

require("cmp_dictionary").setup({
    paths = { "/usr/share/dict/words" },
    first_case_insensitive = true,
    exact_length = 4,
})
