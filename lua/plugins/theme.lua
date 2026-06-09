-- return {
--     "catppuccin/nvim",
--     name = "catppuccin",
--     priority = 1000,
--     config = function()
--         vim.cmd.colorscheme 'catppuccin-mocha'
--         vim.cmd.hi 'Comment gui=none'
--     end,
-- }


return {
    "rose-pine/neovim",
    priority = 1000,
    config = function()
        vim.cmd.colorscheme 'rose-pine'
        vim.cmd.hi 'Comment gui=none'
    end,
}

