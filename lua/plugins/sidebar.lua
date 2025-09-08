return {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
        { "<leader>o", "<cmd>Outline!<CR>", desc = "Toggle outline" },
    },
    opts = {
        outline_window = {
            split_command = "below 15split", -- Command to use to split the window
            width = 15, -- Width of the outline window
            height = 50,     -- Percentage or integer of lines
            show_cursorline = false,
        }
    },
}


