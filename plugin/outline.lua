vim.pack.add({ 'https://github.com/hedyhli/outline.nvim' })

local opts = {
    outline_window = {
        split_command = "below 15split",
        width = 15,
        height = 50,
        show_cursorline = false,
    }
}

require("outline").setup(opts)
vim.keymap.set("n", "<leader>o", require("outline").toggle, { desc = "Toggle outline" })

