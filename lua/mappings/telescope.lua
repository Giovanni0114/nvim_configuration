local builtin = require('telescope.builtin')
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

local buffer_searcher = function()
    builtin.buffers {
        attach_mappings = function(prompt_bufnr, map)
            local refresh_buffer_searcher = function()
                actions.close(prompt_bufnr)
                vim.schedule(buffer_searcher)
            end
            local delete_buf = function()
                local selection = action_state.get_selected_entry()
                vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                refresh_buffer_searcher()
            end
            local delete_multiple_buf = function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selection = picker:get_multi_selection()
                for _, entry in ipairs(selection) do
                    vim.api.nvim_buf_delete(entry.bufnr, { force = true })
                end
                refresh_buffer_searcher()
            end
            map('n', 'dd', delete_buf)
            map('n', '<C-d>', delete_multiple_buf)
            map('i', '<C-d>', delete_multiple_buf)
            return true
        end
    }
end

vim.keymap.set('n', '<leader><leader>', buffer_searcher, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>t.', builtin.oldfiles, { desc = '[T]elescope Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>ta', builtin.find_files, { desc = '[T]elescope All Files' })
vim.keymap.set('n', '<leader>tf', builtin.git_files, { desc = '[T]elescope [F]iles (only git scope)' })
vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = '[T]elescope by [G]rep' })
vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = '[T]elescope [H]elp' })
vim.keymap.set('n', '<leader>tj', builtin.jumplist, { desc = '[T]elescope [J]umplist)' })
vim.keymap.set('n', '<leader>tk', builtin.keymaps, { desc = '[T]elescope [K]eymaps' })
vim.keymap.set('n', '<leader>tm', builtin.marks, { desc = '[T]elescope [M]arks)' })
vim.keymap.set('n', '<leader>tr', builtin.lsp_references, { desc = '[T]elescope [R]esume' })
vim.keymap.set('n', '<leader>tt', builtin.builtin, { desc = '[T]elescope [S]elect Telescope' })
vim.keymap.set('n', '<leader>ts', builtin.git_status, { desc = '[T]elescope [G]it Status' })
vim.keymap.set('n', '<leader>tw', builtin.grep_string, { desc = '[T]elescope current [W]ord' })
vim.keymap.set('n', '<leader>tp', require('telescope').extensions.luasnip.luasnip, { desc = '[T]elescope Tem[P]lates' })


vim.keymap.set('n', '<leader>t/', function()
    builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    }
end, { desc = '[T]elescope [/] in Open Files' })

-- Shortcut for searching neovim configuration files
vim.keymap.set('n', '<leader>nn', function()
    builtin.find_files { cwd = vim.fn.stdpath('config') }
end, { desc = '[N]eovim files' })
