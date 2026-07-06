local function open_markdown(cmd)
  vim.cmd(cmd)
  vim.bo.filetype = 'markdown'
end

vim.api.nvim_create_user_command('Enem', function()
  open_markdown('enew')
end, {})

vim.api.nvim_create_user_command('Enemv', function()
  open_markdown('vnew')
end, {})

vim.api.nvim_create_user_command('Enems', function()
  open_markdown('new')
end, {})
