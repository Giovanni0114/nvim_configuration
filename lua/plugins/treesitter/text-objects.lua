return {
    'nvim-treesitter/nvim-treesitter-textobjects',
    -- lazy = "VeryLazy",
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            textobjects = {
                lsp_interop = {
                    enable = true,
                    border = 'solid',
                    floating_preview_opts = {},
                    peek_definition_code = {
                        ["<leader>df"] = "@function.outer",
                    },
                },
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["ia"] = "@parameter.inner",
                        ["aa"] = "@parameter.outer",
                        ["il"] = "@loop.inner",
                        ["al"] = "@loop.outer",
                    },
                    selection_modes = {
                        ["@class.outer"] = 'V',
                        ["@function.outer"] = 'V',
                        ["@loop.outer"] = 'V',
                    },
                    include_surrounding_whitespace = false,
                },
            },
        })
    end,
}
