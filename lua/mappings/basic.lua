vim.cmd [[nnoremap # <Cmd>let @/='\<'.expand('<cword>').'\>'<bar>set hlsearch<CR>]]
vim.cmd [[nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "remove highlight selection", nowait = true })

vim.keymap.set('n', '<Tab>', '<cmd>tabNext<CR>')

vim.keymap.set('n', '<leader>cp', function()
    vim.fn.setreg('+', vim.fn.expand('%:p'))
    print('Copied full path to clipboard')
end, { desc = 'Copy full file path to clipboard' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Moving indents [gv - select previous visual selection]
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- Buffers
vim.keymap.set('n', '<A-c>', '<C-^>')
-- vim.keymap.set("n", "<A-S-c>", "<cmd>bdelete!<CR>") Changed to BetterBdelete from custom-commands/better-bdelete.lua

vim.keymap.set('n', '<A-PageDown>', '<cmd>cn<CR>')
vim.keymap.set('n', '<A-PageUp>', '<cmd>cp<CR>')

vim.keymap.set("n", "<A-.>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<A-,>", "<cmd>bprevious<CR>")

-- Explore
vim.keymap.set('n', '<leader>e', '<cmd>Explore<CR>')

vim.api.nvim_set_keymap('n', '<A-Up>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Down>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Left>', ':vertical resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Right>', ':vertical resize -2<CR>', { noremap = true, silent = true })


-- quick shortcut to start writing (right alt usage)
vim.keymap.set('n', 'ć', 'ciw')

vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", require("undotree").open)
