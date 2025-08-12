return {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
        { "<leader>o", "<cmd>topleft Outline!<CR>", desc = "Toggle outline" },
    },
    opts = {
        outline_window = {
            position = "left", -- Position of the outline window
            width = 15, -- Width of the outline window
            show_cursorline = false,
        }
    },
}


