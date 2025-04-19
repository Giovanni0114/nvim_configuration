return { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for neovim
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                map('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR><cmd>silent! wa<CR>', "[R]e[N]ame")
                map('<leader>ca', '<cmd>lua vim.lsp.buf.code_action({ apply = true })<CR>', '[C]ode [A]ction')
                map('<leader>cA', '<cmd>lua require("tiny-code-action").code_action()<CR>', '[C]ode [A]ction')
                map('<leader>cs', '<cmd>ClangdSwitchSourceHeader<CR>', '[C]ode [S]witch Source <-> Header')

                map('K', vim.lsp.buf.hover, 'Hover Documentation')
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
            end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
        local servers = {
            clangd = {
                filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
                cmd = { 'clangd', '--clang-tidy', '--offset-encoding=utf-16', '-header-insertion=never'}
            },
            gopls = {},
            pylsp = {},
            lua_ls = {
                filetypes = { "lua" },
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                '${3rd}/luv/library',
                                unpack(vim.api.nvim_get_runtime_file('', true)),
                            },
                        },
                        completion = { callSnippet = 'Replace', },
                        diagnostics = { disable = { 'missing-fields' } },
                    },
                },
            },
        }
        require('mason').setup()
        require('mason-tool-installer').setup { ensure_installed = { 'stylua' } }
        require('mason-lspconfig').setup {
            ensure_installed = { "clangd" },
            automatic_installation = true,
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        }
    end,
}
