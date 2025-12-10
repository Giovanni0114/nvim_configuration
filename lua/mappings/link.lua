vim.api.nvim_set_keymap('n', '<leader>la', ':LinkConvertAll<CR>:%s/\\[\\(\\d\\)\\]/\\[^\\1\\]<CR>', { silent = true })

vim.api.nvim_set_keymap('n', '<leader>lo', ':LinkOpen<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>ll', ':LinkJump<CR>', { silent = true })
