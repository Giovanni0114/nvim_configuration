-- mini.surround
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
vim.keymap.set('n', '<leaders>"', '<cmd> norm saiw"<CR>')
vim.keymap.set('n', "<leader>s'", "<cmd> norm saiw'<CR>")
vim.keymap.set('n', '<leader>s]', '<cmd> norm saiw]<CR>')
vim.keymap.set('n', '<leader>s)', '<cmd> norm saiw)<CR>')
vim.keymap.set('n', '<leader>s>', '<cmd> norm saiw><CR>')

