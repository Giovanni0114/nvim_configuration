vim.api.nvim_set_keymap('n', '<leader>fa', '', {
    noremap = true,
    callback = function()
        local word = vim.fn.expand('<cword>')
        local command = 'vimgrep /\\<' .. word .. '\\>/g **/*'
        vim.cmd(command)
        vim.cmd('copen')
    end,
    desc = 'Search current word with vimgrep (all files)'
})

vim.api.nvim_set_keymap('n', '<leader>fs', '', {
    noremap = true,
    callback = function()
        local word = vim.fn.expand('<cword>')
        local command = 'vimgrep /\\<' .. word .. '\\>/g src/**'
        vim.cmd(command)
        vim.cmd('copen')
    end,
    desc = 'Search current word with vimgrep (src folder)'
})

vim.api.nvim_set_keymap('n', '<leader>fi', '', {
    noremap = true,
    callback = function()
        local word = vim.fn.expand('<cword>')
        local command = 'vimgrep /\\<' .. word .. '\\>/g include/**'
        vim.cmd(command)
        vim.cmd('copen')
    end,
    desc = 'Search current word with vimgrep (include folder)'
})
