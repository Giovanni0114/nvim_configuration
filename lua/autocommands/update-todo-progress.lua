local todo_progress = vim.api.nvim_create_augroup("todo_progress", { clear = true })

-- vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
--     desc = "Update todo progress in virtual text after editing",
--     group = todo_progress,
--     callback = require('progress').update_progress,
-- })
