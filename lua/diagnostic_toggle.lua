local M = {}

function M.toggle()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    vim.notify('diagnostics ' .. (vim.diagnostic.is_enabled() and 'ENABLED' or 'DISABLED'), vim.log.levels.INFO)
end

-- kick everything off disabled when an LSP attaches to a fresh buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group    = vim.api.nvim_create_augroup('diagnostic_toggle', { clear = true }),
    callback = function(ev) -- ev.buf is the buffer that just got an LSP
        if not vim.diagnostic.is_enabled() then
            vim.diagnostic.enable(false)
        end
    end,
})

vim.api.nvim_create_user_command('ToggleDiagnostics', M.toggle, {})
vim.keymap.set('n', '<leader>sd', M.toggle, { desc = 'switch all diagnostics' })

return M
