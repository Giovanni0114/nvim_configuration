return {
    "https://github.com/tpope/vim-fugitive",
    keys = {
        {
            ";",
            -- "<cmd>G!<cr>",
            function()
                if vim.bo.filetype == "fugitive" then
                    vim.cmd("close")
                else
                    vim.cmd("Git!")
                end
            end,
            desc = "Show Neogit UI (preview)"
        },

        -- { "", "<cmd>G<cr>", desc = "Show Neogit UI" }
    },
}
