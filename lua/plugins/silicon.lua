-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'michaelrommel/nvim-silicon',
  lazy = true,
  cmd = 'Silicon',
  config = function()
    require('silicon').setup {
      to_clipboard = true,
      font = 'JetBrainsMono Nerd Font=34;Noto Color Emoji=34',
      theme = 'Coldark-Dark',
      output = function()
        return '/tmp/' .. os.date '!%Y-%m-%dT%H-%M-%S' .. '_code.png'
      end,
      no_window_controls = true,
      window_title = function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ':t')
      end,
    }
  end,
}
