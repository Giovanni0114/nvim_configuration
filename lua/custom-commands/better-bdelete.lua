local function better_bdelete()
    local cur = vim.api.nvim_get_current_buf()
    local alt = vim.fn.bufnr('#')

    local has_alt = alt > 0
        and alt ~= cur
        and vim.api.nvim_buf_is_valid(alt)
        and vim.fn.buflisted(alt) == 1

    if has_alt then
        vim.cmd('buffer #')
    else
        vim.cmd('enew')
    end

    pcall(vim.cmd, 'bdelete ' .. cur)
end

vim.api.nvim_create_user_command('BetterBdelete', better_bdelete, {})
vim.keymap.set('n', '<A-S-c>', better_bdelete, { desc = 'Better buffer delete (keep window)' })
