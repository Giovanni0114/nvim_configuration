-- i will create the system to have some machine specific file in some git
-- ignored file that will specfy the which lsp server should be enabled

local function disable_highlight(lsp)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "clangd" then
                client.server_capabilities.semanticTokensProvider = nil
            end
        end,
    })
end

vim.lsp.enable({ "lua-ls" })
vim.lsp.enable({ "clangd" })
vim.lsp.enable({ "pylsp" })
vim.lsp.enable({ "rust" })
vim.lsp.enable({ "html" })
vim.lsp.enable({ "json" })

vim.diagnostic.config({ virtual_text = true })

-- disable_highlight("clangd") -- unused for now


-- what if I want to disable all higlighs in all lsp servers?
-- treesitter based highlighting should be enough
--
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        client.server_capabilities.semanticTokensProvider = nil
    end,
})
