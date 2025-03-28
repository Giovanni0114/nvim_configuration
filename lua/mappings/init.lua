require "mappings.git-mappings"
require "mappings.vimgrep-search"
require "mappings.telescope"


vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { desc = 'Formatting' })
vim.keymap.set('v', 'f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { desc = 'LSP formatting range' })

-- Utils 
vim.keymap.set("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text" })
vim.cmd [[nnoremap # <Cmd>let @/='\<'.expand('<cword>').'\>'<bar>set hlsearch<CR>]]
vim.cmd [[nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "remove hightlight selection" })

-- Explore
vim.keymap.set('n', '<leader>ne', '<cmd>Texplore<CR>')
vim.keymap.set('n', '<leader>e', '<cmd>Explore<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [D]iagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-Left>', '<C-w><C-h>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-Right>', '<C-w><C-l>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-Down>', '<C-w><C-j>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-Up>', '<C-w><C-k>', { noremap = true, silent = true })

-- Formatting

-- Moving indents [gv - select previous visual selection]
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- Buffers
-- vim.keymap.set("n", "<A-c>", "<cmd>bdelete<CR>")
-- vim.keymap.set("n", "<A-c>", "<cmd>echom 'not that you moron'<CR>")

vim.api.nvim_set_keymap('n', '<A-c>', '<C-^>', { noremap = true, silent = true })
vim.keymap.set("n", "<A-S-c>", "<cmd>bdelete!<CR>")

vim.keymap.set('n', '<A-S-.>', '<cmd>cn<CR>')
vim.keymap.set('n', '<A-S-,>', '<cmd>cp<CR>')

vim.keymap.set("n", "<A-.>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<A-,>", "<cmd>bprevious<CR>")

vim.keymap.set("n", "<C-.>", "<cmd>Gitsigns next_hunk<CR>")
vim.keymap.set("n", "<C-,>", "<cmd>Gitsigns prev_hunk<CR>")

vim.api.nvim_set_keymap('n', '<A-Up>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Down>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Left>', ':vertical resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Right>', ':vertical resize -2<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Prev todo" })

vim.keymap.set("n", "<leader>cc", "<cmd>lua require('treesitter-context').go_to_context(vim.v.count1)<CR>",
    { desc = "go to context" })

