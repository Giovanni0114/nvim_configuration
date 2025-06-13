-- i will create the system to have some machine specific file in some git
-- ignored file that will specfy the which lsp server should be enabled
-- 
-- also formatting is problematic, maybe i should familiarize with null-ls or
-- check how lspconfig did it

vim.lsp.enable({"lua_ls"})
vim.lsp.enable({"clangd"}) 
vim.lsp.enable({"pylsp"})
vim.lsp.enable({"rust"})

vim.diagnostic.config({ virtual_text = true })

