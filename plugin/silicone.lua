vim.pack.add({ "https://github.com/michaelrommel/nvim-silicon" })

require('nvim-silicon').setup {
    to_clipboard = true,
    font = 'JetBrainsMono Nerd Font=34;Noto Color Emoji=34',
    theme = 'Dracula',
    output = function()
        return '/tmp/' .. os.date '!%Y-%m-%dT%H-%M-%S' .. '_code.png'
    end,
    no_window_controls = true,
    window_title = function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ':t')
    end,
    line_offset = function(args)
        return args.line1
    end,
    num_separator = "\u{258f} ",
}
