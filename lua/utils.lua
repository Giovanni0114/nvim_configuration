
-- Load all Lua scripts from the specified folder
local load_scripts_from_path = function(folder, raw)
    local p = io.popen("ls " .. folder)
    for file in p:lines() do
        if file:match("^(.*)%.lua$") then
            local module = file:sub(1, -5)
            require(raw .. "." .. module)
        end
    end
    p:close()
end

M = {}

M.load_scripts = function(raw)
    folder = vim.fn.stdpath('config') .. '/lua/' .. raw
    if not folder or folder == ""  or vim.fn.isdirectory(folder) == 0 then
        print("Error: " .. folder .. " is not a directory")
        return
    end
    load_scripts_from_path(folder, raw)
end

return M
