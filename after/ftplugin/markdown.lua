vim.opt_local.conceallevel = 2
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2

vim.g.copilot_enabled = 0

require('render-markdown').enable()

vim.keymap.set("n", "<C-m>", ":ToggleCheckbox<CR>j", { noremap = true, silent = true, buffer = vim.api.nvim_get_current_buf()})

