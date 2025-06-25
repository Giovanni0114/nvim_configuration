vim.api.nvim_create_autocmd('LspAttach', {
    group    = vim.api.nvim_create_augroup('diagnostic_toggle', { clear = true }),
    callback = function(ev) -- ev.buf is the buffer that just got an LSP
        if not vim.diagnostic.is_enabled() then
            vim.diagnostic.enable(false)
        end
    end,
})

