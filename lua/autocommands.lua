-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_augroup("JumpOnBdelete", { clear = true })

vim.api.nvim_create_autocmd("BufDelete", {
    group = "JumpOnBdelete",
    callback = function()
        vim.fn.setpos(".", vim.fn.getpos("."))
    end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        map('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR><cmd>silent! wa<CR>', "[R]e[N]ame")
        map('<leader>ca', '<cmd>lua vim.lsp.buf.code_action({ apply = true })<CR>', '[C]ode [A]ction')
        map('<leader>cA', '<cmd>lua require("tiny-code-action").code_action()<CR>', '[C]ode [A]ction')

        -- map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gd', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    end,
})
