vim.api.nvim_buf_create_user_command(0, 'HexAssemble', function()
	require('hex').assemble()
end, { desc = 'HexAssemble' })

vim.api.nvim_buf_create_user_command(0, 'HexDump', function()
	require('hex').dump()
end, { desc = 'HexDump' })

vim.api.nvim_buf_create_user_command(0, 'HexToggle', function()
	require('hex').toggle()
end, { desc = 'HexToggle' })

return { 'RaafatTurki/hex.nvim' }
