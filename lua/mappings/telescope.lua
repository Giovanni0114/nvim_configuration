local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>t.', builtin.oldfiles, { desc = '[T]elescope Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>ta', builtin.find_files, { desc = '[T]elescope All Files' })
vim.keymap.set('n', '<leader>td', builtin.diagnostics, { desc = '[T]elescope [D]iagnostics' })
vim.keymap.set('n', '<leader>tf', builtin.git_files, { desc = '[T]elescope [F]iles (only git scope)' })
vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = '[T]elescope by [G]rep' })
vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = '[T]elescope [H]elp' })
vim.keymap.set('n', '<leader>tj', builtin.jumplist, { desc = '[T]elescope [J]umplist)' })
vim.keymap.set('n', '<leader>tk', builtin.keymaps, { desc = '[T]elescope [K]eymaps' })
vim.keymap.set('n', '<leader>tm', builtin.marks, { desc = '[T]elescope [M]arks)' })
vim.keymap.set('n', '<leader>tr', builtin.lsp_references, { desc = '[T]elescope [R]esume' })
vim.keymap.set('n', '<leader>ts', builtin.builtin, { desc = '[T]elescope [S]elect Telescope' })
vim.keymap.set('n', '<leader>tw', builtin.grep_string, { desc = '[T]elescope current [W]ord' })

-- See lua/telescope-pickers/better-buffer-picker.lua
-- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

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
end, { desc = '[T]elescope [/] in Open Files' })

-- Shortcut for searching your neovim configuration files
vim.keymap.set('n', '<leader>nn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[N]eovim files' })
