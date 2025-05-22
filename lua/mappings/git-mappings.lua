-- git signs 
vim.keymap.set("n", "<leader>rh", "<cmd>lua require('gitsigns').reset_hunk()<CR>", { desc = "Restore hunk" })
vim.keymap.set("n", "<leader>rb", "<cmd>lua require('gitsigns').reset_buffer()<CR>", { desc = "Restore buffer" })
vim.keymap.set("n", "<leader>dc", "<cmd>lua require('gitsigns').toggle_deleted()<CR>", { desc = "Show deleted" })
vim.keymap.set("n", "<leader>gb", "<cmd>lua require('gitsigns').blame_line()<CR>", { desc = "Show deleted" })

vim.keymap.set("n", "<leader>bt", "<cmd>BlameToggle virtual<CR>", { desc = "Git Balme Toggle (virtual)" })

vim.keymap.set("n", "<C-s>", "<cmd>Gitsigns next_hunk<CR>")
-- vim.keymap.set("n", "<C-,>", "<cmd>Gitsigns prev_hunk<CR>")

