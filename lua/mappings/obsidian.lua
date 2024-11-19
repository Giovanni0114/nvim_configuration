
vim.keymap.set('n', '<leader>oo', '<cmd>lua require("obsidian")<CR>', { desc = '[O]bsidian Launch' })

vim.keymap.set('n', '<leader>oq', '<cmd>ObsidianQuickSwitch<CR>', { desc = '[O]bsidian [Q]uick Switch' })
vim.keymap.set('n', '<leader>os', '<cmd>ObsidianSearch<CR>', { desc = '[O]bsidian [S]earch' })
vim.keymap.set('n', '<leader>or', '<cmd>ObsidianRename<CR>', { desc = '[O]bsidian [R]ename' })
vim.keymap.set('n', '<leader>ow', '<cmd>ObsidianWorkspace<CR>', { desc = '[O]bsidian [W]orkspace' })
vim.keymap.set('n', '<leader>oe', '<cmd>ObsidianExtractNote<CR>', { desc = '[O]bsidian [E]xtract Note' })
vim.keymap.set('n', '<leader>ot', '<cmd>ObsidianTags<CR>', { desc = '[O]bsidian [T]ags' })
vim.keymap.set('n', '<leader>on', '<cmd>ObsidianNew<CR>', { desc = '[O]bsidian [N]ew' })
vim.keymap.set('n', '<leader>ol', '<cmd>ObsidianLinks<CR>', { desc = '[O]bsidian [L]inks' })

vim.keymap.set('n', '<leader>odd', '<cmd>ObsidianDailies -12 3<CR>', { desc = '[O]bsidian [D]ailies [D]ailies' })
vim.keymap.set('n', '<leader>ody', '<cmd>ObsidianYesterday<CR>', { desc = '[O]bsidian [D]ailies [Y]esterday' })
vim.keymap.set('n', '<leader>odt', '<cmd>ObsidianTomorrow<CR>', { desc = '[O]bsidian [D]ailies [T]omorrow' })
vim.keymap.set('n', '<leader>odn', '<cmd>ObsidianToday<CR>', { desc = '[O]bsidian [D]ailies [N]ow' })

