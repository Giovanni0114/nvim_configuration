require('opts')

local utils = require('utils')
local lsp_folder = vim.fn.stdpath('config') .. '/' .. 'lsp'

vim.lsp.enable(utils.load_filenames_from_path(lsp_folder))
vim.diagnostic.config({ virtual_text = true })

utils.load_scripts('custom-commands')
utils.load_scripts('mappings')
utils.load_scripts('autocommands')
