local M = {}
local entry

local function owned_directory(path, uid)
    local info = vim.uv.fs_lstat(path)
    return info and info.type == 'directory' and info.uid == uid and bit.band(info.mode, 63) == 0
end

local function registry_dir(uid)
    local base = vim.env.XDG_RUNTIME_DIR
    if not base or base == '' then
        local user_runtime = '/run/user/' .. uid
        if owned_directory(user_runtime, uid) then
            base = user_runtime
        else
            return '/tmp/opencode-present-' .. uid
        end
    end
    if not owned_directory(base, uid) then
        error('Present: runtime directory is not private and owned by this user')
    end
    return vim.fs.joinpath(base, 'opencode-present')
end

function M.path()
    return registry_dir(vim.uv.os_get_passwd().uid)
end

function M.start()
    if entry then return end
    local uid = vim.uv.os_get_passwd().uid
    local directory = M.path()
    local ok, err = vim.uv.fs_mkdir(directory, 448)
    if not ok and not vim.uv.fs_lstat(directory) then
        error('Present: cannot create registry: ' .. tostring(err))
    end
    if not owned_directory(directory, uid) then
        error('Present: registry is not private and owned by this user')
    end
    local socket = vim.v.servername
    if not socket or socket == '' then error('Present: Neovim has no server socket') end
    local pid = vim.fn.getpid()
    local suffix = vim.fn.sha256(socket .. tostring(vim.uv.hrtime())):sub(1, 16)
    local path = vim.fs.joinpath(directory, pid .. '-' .. suffix .. '.json')
    local contents = vim.json.encode({ pid = pid, socket = socket })
    local fd, open_err = vim.uv.fs_open(path, 'wx', 384)
    if not fd then error('Present: cannot register editor: ' .. tostring(open_err)) end
    local written, write_err = vim.uv.fs_write(fd, contents, 0)
    local info = vim.uv.fs_fstat(fd)
    vim.uv.fs_close(fd)
    if written ~= #contents then
        vim.uv.fs_unlink(path)
        error('Present: cannot write editor registration: ' .. tostring(write_err))
    end
    entry = { path = path, contents = contents, ino = info.ino, uid = uid }
    vim.api.nvim_create_autocmd('VimLeavePre', {
        once = true,
        callback = function()
            local current = vim.uv.fs_lstat(entry.path)
            if not current or current.type ~= 'file' or current.uid ~= entry.uid or current.ino ~= entry.ino then
                return
            end
            local lines = vim.fn.readfile(entry.path, 'b')
            if table.concat(lines, '\n') == entry.contents then vim.uv.fs_unlink(entry.path) end
        end,
    })
end

return M
