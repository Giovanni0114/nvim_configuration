vim.api.nvim_create_autocmd({
    "BufWritePost",
    "FocusGained",
    "TermClose",
    "FileChangedShellPost",
}, {
    group = vim.api.nvim_create_augroup(
        "FugitiveRefresh", { clear = true }
    ),
    callback = function()
        if vim.fn.exists("*FugitiveDidChange") == 1 then
            vim.fn.FugitiveDidChange(0)
        end
    end,
})
