local M = {}

function M.dispatch(request, alive)
    local review = require('present.review')
    if request.op == 'open' then
        return review.open(request.manifest, request.decision_socket, request.id, alive)
    elseif request.op == 'dirty' then
        return { paths = review.dirty(request.manifest) }
    elseif request.op == 'lock' then
        return review.lock(request.manifest, request.id, request.lease_socket)
    elseif request.op == 'unlock' then
        return review.unlock(request.id)
    elseif request.op == 'close' then
        return review.close(request.id)
    elseif request.op == 'refresh' then
        return review.refresh(request.manifest)
    elseif request.op == 'notify' then
        local level = request.outcome.status == 'error' and vim.log.levels.ERROR or vim.log.levels.INFO
        vim.schedule(function() vim.notify('Present: ' .. request.outcome.detail, level) end)
        return { ok = true }
    end
    return { error = 'unknown_operation' }
end

function M.dispatch_file(path)
    local directory = require('present.registry').path()
    local normalized = vim.fs.normalize(path)
    if vim.fs.dirname(normalized) ~= directory or not vim.fs.basename(normalized):match('^rpc%-.+%.json$') then
        error('Present: invalid RPC request path')
    end
    local info = vim.uv.fs_lstat(normalized)
    local uid = vim.uv.os_get_passwd().uid
    if not info or info.type ~= 'file' or info.uid ~= uid or bit.band(info.mode, 63) ~= 0 then
        error('Present: unsafe RPC request file')
    end
    local fd = assert(vim.uv.fs_open(normalized, 'r', 0))
    local opened = vim.uv.fs_fstat(fd)
    if opened.ino ~= info.ino or opened.dev ~= info.dev then
        vim.uv.fs_close(fd)
        error('Present: RPC request changed while opening')
    end
    local contents = assert(vim.uv.fs_read(fd, opened.size, 0))
    vim.uv.fs_close(fd)
    local function alive()
        local current = vim.uv.fs_lstat(normalized)
        return current and current.type == 'file' and current.dev == info.dev and current.ino == info.ino
    end
    return vim.json.encode(M.dispatch(vim.json.decode(contents), alive))
end

return M
