vim.api.nvim_create_user_command('Enem', function()
  vim.cmd('enew')
  vim.bo.filetype = 'markdown'
end, {})
