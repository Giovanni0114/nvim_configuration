
-- Load all Lua scripts from the specified folder
local load_scripts_from_path = function(folder, raw)
    local iter, err = vim.loop.fs_scandir(folder)
    if not iter then
        print("Error: Unable to scan directory " .. folder .. ": " .. err)
        return
    end
    while true do
        local file = vim.loop.fs_scandir_next(iter)
        if not file then break end
        if file:match("^(.*)%.lua$") then
            local module = file:sub(1, -5)
            require(raw .. "." .. module)
        end
    end
end

M = {}

M.load_scripts = function(raw)
    local folder = vim.fn.stdpath('config') .. '/lua/' .. raw
    if not folder or folder == ""  or vim.fn.isdirectory(folder) == 0 then
        print("Error: " .. folder .. " is not a directory")
        return
    end
    load_scripts_from_path(folder, raw)
end

return M
