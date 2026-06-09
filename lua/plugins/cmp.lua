return {
    'hrsh7th/nvim-cmp',
    lazy = "VeryLazy",
    event = 'InsertEnter',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build = (function()
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                'rafamadriz/friendly-snippets',
            },
        },
        'benfowler/telescope-luasnip.nvim',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        'uga-rosa/cmp-dictionary',
        "vim-dadbod-completion"
    },

    config = function()
        -- See `:help cmp`
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        luasnip.config.setup {}

        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

        local function priority_comparator(entry1, entry2)
            local p1 = entry1.source:get_source_config().priority or 0
            local p2 = entry2.source:get_source_config().priority or 0

            local diff = p1 - p2
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

            cmp.mapping,

            mapping = cmp.mapping.preset.insert {
                ['<Tab>'] = cmp.mapping.select_next_item(),
                ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                ['<Enter>'] = cmp.mapping.confirm {},
                ['<C-Space>'] = cmp.mapping.complete {},
            },

            sources = {
                { name = 'nvim_lsp',             priority = 10, },
                { name = 'luasnip' },
                { name = 'path' },
                { name = 'buffer',               priority = -10, },
                { name = "vim-dadbod-completion" },
                { name = 'render-markdown' },
                {
                    name = "dictionary",
                    keyword_length = 4,
                    priority = -100
                },

            },

            sorting = {
                comparators = {
                    priority_comparator,
                    cmp.config.compare.kind,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                },
            },
        }
        require("cmp_dictionary").setup({
            paths = { "/usr/share/dict/words" },
            first_case_insensitive = true,
            exact_length = 4,
        })
    end,
}
