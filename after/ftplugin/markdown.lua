vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

-- Key mappings for toggling checkboxes in markdown files
vim.keymap.set("n", "<C-m>", function()
    local bufnr = vim.api.nvim_buf_get_number(0)
    local cursor = vim.api.nvim_win_get_cursor(0)
    require("checkbox-toggle").toggle_line(bufnr, cursor)
end, { noremap = true, silent = true })


-- Key mappings for toggling checkboxes in markdown files
vim.keymap.set("n", "<C-\\>", function()
    local bufnr = vim.api.nvim_buf_get_number(0)
    local cursor = vim.api.nvim_win_get_cursor(0)
    require("checkbox-toggle").cycle_next_char(bufnr, cursor)
end, { noremap = true, silent = true })
