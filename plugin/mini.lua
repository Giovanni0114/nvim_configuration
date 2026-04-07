vim.pack.add({ 'https://github.com/echasnovski/mini.nvim' })

-- https://github.com/echasnovski/mini.nvim
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.align').setup()

local statusline = require 'mini.statusline'
statusline.setup()

statusline.section_location = function()
    return (require('copilot').setup_done and ' on ' or '') .. '%p%%'
end
