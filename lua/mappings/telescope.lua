local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>tk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>tf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ts', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>tw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>td', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>tr', builtin.lsp_references, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>t.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>t/', function()
    builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your neovim configuration files
vim.keymap.set('n', '<leader>nn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'T/tabab [N]eovim files' })
