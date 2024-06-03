local function readFromFile(filePath)
    local file = io.open(filePath, "r") -- Open the file in read mode
    if not file then
        return
    end
    local content = file:read("*all") -- Read the entire file
    file:close()
    return string.sub(content, 1, -2)
end
Toolchain = ""
-- Read from the file
Toolchain = readFromFile("./.toolchain")
if os.getenv("TOOLCHAIN") ~= nil then
    Toolchain = os.getenv("TOOLCHAIN")
end

if Toolchain ~= "" then
    Toolchain = string.upper(Toolchain or "")
    print("selected " .. Toolchain .. " toolchain")
end

local paths = {
    ["VMMB2"] =
    '--query-driver=/home/giovanni/ASD/toolchain/vmmb2/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["VMMB3"] =
    '--query-driver=/home/giovanni/ASD/toolchain/vmmb3/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["X86_64"] =
    '--query-driver=/home/giovanni/ASD/toolchain/genericx86-64/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*',
    ["OC"] = '--query-driver=/home/giovanni/ASD/toolchain/ofonoconnman/sysroots/x86_64-podsdk-linux/usr/bin/*/*podos-linux-g*',
    ["BUILDROOT"] = '--query-driver=/home/giovanni/ASD/buildroot/output/host/bin/arm-linux-*',
}

Clang_CMD = { 'clangd', '--clang-tidy', '--offset-encoding=utf-16', '-header-insertion=never', paths[Toolchain] or nil }

local exit_code = io.popen "grep -q 'latte' ~/.config/alacritty/alacritty.toml \necho _$?":read '*a':match '.*%D(%d+)' +
0

if exit_code == 0 then
    vim.opt.background = "light"
else
    vim.opt.background = "dark"
end

require("main")
