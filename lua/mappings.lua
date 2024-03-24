vim.keymap.set('n', '<leader>ne', '<cmd>Texplore<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>Explore<CR>')

vim.keymap.set('n', '<leader>x', '<cmd>close<CR>')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- surrondings
vim.keymap.set('n', '<leader>s"', '<cmd> norm saiw"<CR>')
vim.keymap.set('n', "<leader>s'", "<cmd> norm saiw'<CR>")
vim.keymap.set('n', '<leader>s]', '<cmd> norm saiw]<CR>')
vim.keymap.set('n', '<leader>s)', '<cmd> norm saiw)<CR>')
vim.keymap.set('n', '<leader>s>', '<cmd> norm saiw><CR>')

vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { desc = 'Formatting' })
vim.keymap.set('v', 'f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { desc = 'LSP formatting range' })
vim.keymap.set('n', '<leader>ff', "<cmd>lua require('conform').format()<CR>", { desc = 'Formatting' })
vim.keymap.set('v', 'af', "<cmd>lua require('conform').format()<CR>", { desc = 'alt formatting' })

vim.keymap.set("n", "<leader>rh", "<cmd>lua require('gitsigns').reset_hunk()<CR>", { desc = "Restore hunk" })
vim.keymap.set("n", "<leader>rb", "<cmd>lua require('gitsigns').reset_buffer()<CR>", { desc = "Restore buffer" })
vim.keymap.set("n", "<leader>sd", "<cmd>lua require('gitsigns').toggle_deleted()<CR>", { desc = "Show deleted" })
vim.keymap.set("n", "<leader>gb", "<cmd>lua require('gitsigns').blame_line()<CR>", { desc = "Show deleted" })

vim.keymap.set("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text" })

-- moving indents 
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

vim.keymap.set("n", "<A-c>", "<cmd>bdelete<CR>")


