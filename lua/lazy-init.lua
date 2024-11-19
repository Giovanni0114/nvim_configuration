-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
    {
        'numToStr/Comment.nvim',
        opts = {}
    },

    -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false }
    },
    {                       -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require('which-key').setup {
                notify = false,
            }

            -- Document existing key chains
            require('which-key').register {
                ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
                ['<leader>t'] = { name = '[T]elescope', _ = 'which_key_ignore' },
                ['<leader>o'] = { name = '[O]bsidian', _ = 'which_key_ignore' },
            }
        end,
    },
    {
        'catppuccin/nvim',
        flavour = "auto",
        name = 'catppuccin',
        priority = 1000,
        config = function()
            -- Load the colorscheme here
            vim.cmd.colorscheme 'catppuccin'

            -- You can configure highlights by doing something like
            vim.cmd.hi 'Comment gui=none'
        end,
    },
    -- {
    --     "0xstepit/flow.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = {},
    --     config = function()
    --         require("flow").setup {
    --             transparent = true, -- Set transparent background.
    --             fluo_color = "pink", --  Fluo color: pink, yellow, orange, or green.
    --             mode = "normal", -- Intensity of the palette: normal, bright, desaturate, or dark. Notice that dark is ugly!
    --             aggressive_spell = false, -- Display colors for spell check.
    --         }
    --
    --         vim.cmd "colorscheme flow"
    --     end,
    -- },

    { import = 'plugins' },
    { import = 'plugins.mini' },
    { import = 'plugins.lsp' },
    { import = 'plugins.git' },
}
