return {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
        { "<leader>o", "<cmd>Outline!<CR>", desc = "Toggle outline" },
    },
    opts = {
        outline_window = {
            position = "right", -- Position of the outline window
            width = 15, -- Width of the outline window
            show_cursorline = false,
        }
    },
}


