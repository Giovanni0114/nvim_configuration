vim.pack.add({ 'https://github.com/echasnovski/mini.nvim' })

-- https://github.com/echasnovski/mini.nvim
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.align').setup()

local statusline = require 'mini.statusline'
statusline.setup()

statusline.section_location = function()
    local is_copilot_enabled = require('copilot').setup_done
    local is_sidekick_nes_enabled = require('sidekick.nes').enabled

    return ((is_copilot_enabled or is_sidekick_nes_enabled) and ' on ' or '') .. '%p%%'
end
