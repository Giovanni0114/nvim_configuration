-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })

vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [Q]uickfix list' })

vim.keymap.set('n', '<leader>dt', function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    vim.notify('diagnostics ' .. (vim.diagnostic.is_enabled() and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end, { desc = '[L]sp diagnostics [T]oggle' })

-- Formatting
vim.keymap.set('n', '<leader>fm', function() vim.lsp.buf.format({ async = true }) end, { desc = 'Formatting' })
vim.keymap.set('v', 'f', function() vim.lsp.buf.format({ async = true }) end, { desc = 'LSP formatting range' })
