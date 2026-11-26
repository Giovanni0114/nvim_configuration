local ok, err = pcall(function() require('present.registry').start() end)
if not ok then
    vim.schedule(function() vim.notify(tostring(err), vim.log.levels.WARN) end)
end
