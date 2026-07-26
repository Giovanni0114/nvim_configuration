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

require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

require("cmp_dictionary").setup({
    paths = { "/usr/share/dict/words" },
    first_case_insensitive = true,
    exact_length = 4,
})

local function priority_comparator(entry1, entry2)
    local diff = entry1.source:get_source_config().priority - entry2.source:get_source_config().priority
    if diff > 0 then
        return true
    elseif diff < 0 then
        return false
    end
    return nil
end


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
        { name = 'nvim_lsp',              priority = 10 },
        { name = 'luasnip',               priority = 0 },
        { name = 'path',                  priority = 0 },
        { name = 'buffer',                priority = 0 },
        { name = "vim-dadbod-completion", priority = 0 },
        { name = 'render-markdown',       priority = 0 },
        { name = "dictionary",            priority = -100, keyword_length = 4 },
    },
    sorting = {
        comparators = {
            priority_comparator,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.exact,
        },
    },
}
