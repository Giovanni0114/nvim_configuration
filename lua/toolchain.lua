local customPaths         = {
    ["BUILDROOT"] = "/home/giovanni/ASD/toolchain/buildroot/output/host/bin/arm-buildroot-linux-gnueabi-g*",
    ["TEST"] = "/home/giovanni/ASD/test_wersji/v3/sysroots/x86_64-podsdk-linux/usr/bin/*/*-g*",
}

local aliases        = {
    ["OC"] = "ofonoconnman",
    ["X86"] = "genericx86-64",
    ["X86_64"] = "genericx86-64",
    ["VENDOS-X86_64"] = "vendos-genericx86-64",
    ["VENDOS-VMMB3"] = "vendos-vmmb3",
}


local toolchainsPathPrefix = "/home/giovanni/ASD/toolchain/"
local clangPrefix         = "--query-driver="
local vendosPathSuffix    = "/sysroots/x86_64-vendsdk-linux/usr/bin/*vendos*/*vendos-linux-g*"
local podosPathSuffix     = "/sysroots/x86_64-podsdk-linux/usr/bin/*podos*/*podos-linux-g*"

---@param toolchainName string
local function getPodosToolchainName(toolchainName)
    if aliases[toolchainName] ~= nil then
        return aliases[toolchainName]
    end

    return toolchainName
end

local function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

---@param filePath string
local function readFromFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return
    end
    local content = file:read("*all")
    file:close()
    return string.sub(content, 1, -2)
end

local toolchain = readFromFile("./.toolchain") or ""

if toolchain == "" then
    print("no toolchain selected")
    return "--pretty"
end

toolchain = string.upper(toolchain or "")

if customPaths[toolchain] ~= nil then
    print("selected custom " .. toolchain .. " toolchain")
    return clangPrefix .. customPaths[toolchain]
end

local podosToolchain = getPodosToolchainName(toolchain)
local podosPath = toolchainsPathPrefix .. string.lower(podosToolchain)
local suffix = string.match(podosToolchain, "vendos") and vendosPathSuffix or podosPathSuffix

if exists(podosPath .. "/") then
    print("selected podos " .. toolchain .. " toolchain")
    return clangPrefix .. podosPath .. suffix
end

print("no toolchain selected but something is wrong")

return "--pretty"
