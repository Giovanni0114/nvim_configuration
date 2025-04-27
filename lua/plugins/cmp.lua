return { -- Autocompletion
    'hrsh7th/nvim-cmp',
    lazy = "VeryLazy",
    event = 'InsertEnter',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build = (function()
                return 'make install_jsregexp'
            end)(),
        },
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        "vim-dadbod-completion",
        {
            "zbirenbaum/copilot-cmp",
            event = "InsertEnter",
            -- config = function () require("copilot_cmp").setup() end,
        },
    },

    config = function()
        -- See `:help cmp`
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        luasnip.config.setup {}
    
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
                ['<Enter>'] = cmp.mapping.confirm { select = true },

                -- Manually trigger a completion
                ['<C-Space>'] = cmp.mapping.complete {},
            },

            sources = {
                -- { name = 'copilot' },
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'path' },
                { name = 'buffer' },
                { name = "vim-dadbod-completion" },
                { name = 'render-markdown' },
            },
        }
    end,
}
