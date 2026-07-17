local lsp_folder = vim.fn.stdpath('config') .. '/' .. 'lsp'
vim.lsp.enable(require("utils").load_filenames_from_path(lsp_folder))

vim.diagnostic.config({ virtual_text = true })
