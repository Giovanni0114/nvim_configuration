vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('K', require("pretty_hover").hover,  'pretty hover' )

        map('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR><cmd>silent! wa<CR>', "[R]e[N]ame")
        map('<leader>ca', '<cmd>lua vim.lsp.buf.code_action({ apply = true })<CR>', '[C]ode [A]ction')
        map('<leader>cA', '<cmd>lua require("tiny-code-action").code_action()<CR>', '[C]ode [A]ction')

        map('gd', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    end,
})
