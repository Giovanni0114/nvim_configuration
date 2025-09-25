local lsp_folder = vim.fn.stdpath('config') .. '/' .. 'lsp'
vim.lsp.enable(require("utils").load_filenames_from_path(lsp_folder))

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

vim.diagnostic.config({ virtual_text = true })
