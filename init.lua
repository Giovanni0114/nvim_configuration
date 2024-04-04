local function readFromFile(filePath)
    local file = io.open(filePath, "r") -- Open the file in read mode
    if not file then
        return
    end
    local content = file:read("*all") -- Read the entire file
    file:close()
    return string.sub(content, 1, -2)
end

-- Read from the file
local toolchain = readFromFile("./.toolchain")
if os.getenv("TOOLCHAIN") ~= nil then
    toolchain = os.getenv("TOOLCHAIN")
end

local paths = {
    ["VMMB2"] =
    '--query-driver=/home/giovanni/ASD/toolchain/vmmb2/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["VMMB3"] =
    '--query-driver=/home/giovanni/ASD/toolchain/vmmb3/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["x86_64"] =
    '--query-driver=/home/giovanni/ASD/toolchain/genericx86-64/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
}

Clang_CMD = { 'clangd', '--clang-tidy', '--offset-encoding=utf-16', '-header-insertion=never', paths[toolchain] or nil }

require("main")
