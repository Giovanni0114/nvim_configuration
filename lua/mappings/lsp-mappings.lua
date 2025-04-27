-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [Q]uickfix list' })

-- Formatting
vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { desc = 'Formatting' })
vim.keymap.set('v', 'f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { desc = 'LSP formatting range' })
