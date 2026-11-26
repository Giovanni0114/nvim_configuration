local M = {}
local reviews = {}
local locks = {}
local protected = {}
local sequence = 0

local function value_or_nil(value)
    if value == vim.NIL then return nil end
    return value
end

local function canonical(path)
    return vim.uv.fs_realpath(path) or vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
end

local function targets_for(manifest)
    local targets = {}
    for _, change in ipairs(manifest.changes) do
        targets[canonical(vim.fs.joinpath(manifest.root, change.path))] = change.path
    end
    return targets
end

function M.dirty(manifest)
    local targets = targets_for(manifest)
    local found = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= '' then
                local path = targets[canonical(name)]
                if path then found[path] = true end
            end
        end
    end
    local paths = vim.tbl_keys(found)
    table.sort(paths)
    return paths
end

local function lock_buffer(lock, buf)
    if not vim.api.nvim_buf_is_loaded(buf) then return end
    local name = vim.api.nvim_buf_get_name(buf)
    local path = name ~= '' and canonical(name) or nil
    if not path or not lock.targets[path] then return end
    if vim.bo[buf].modified then
        lock.conflicts[lock.targets[path]] = true
        return
    end
    local existing = protected[buf]
    if existing and existing.name ~= path then
        for owner in pairs(existing.owners) do
            if locks[owner] then locks[owner].buffers[buf] = nil end
        end
        protected[buf] = nil
        existing = nil
    end
    if existing then
        if vim.bo[buf].modifiable then lock.conflicts[lock.targets[path]] = true end
        existing.owners[lock.id] = true
        lock.buffers[buf] = true
        return
    end
    protected[buf] = { name = path, modifiable = vim.bo[buf].modifiable, owners = { [lock.id] = true } }
    lock.buffers[buf] = true
    vim.bo[buf].modifiable = false
end

local function close_lease(lock)
    local pipe = lock.lease
    lock.lease = nil
    if pipe and not pipe:is_closing() then
        pcall(function() pipe:read_stop() end)
        pipe:close()
    end
end

local function start_lease(lock, lease_socket)
    local pipe = vim.uv.new_pipe(false)
    lock.lease = pipe
    local function disconnected()
        vim.schedule(function()
            if locks[lock.id] == lock then
                M.unlock(lock.id)
                vim.notify('Present: application interrupted; editor buffers unlocked', vim.log.levels.WARN)
            end
        end)
    end
    pipe:connect(lease_socket, function(err)
        if err then close_lease(lock); disconnected(); return end
        pipe:write(vim.json.encode({ kind = 'lease', id = lock.id, pid = vim.fn.getpid() }) .. '\n', function(write_err)
            if write_err then close_lease(lock); disconnected(); return end
            pipe:read_start(function(read_err, data)
                if read_err or not data then close_lease(lock); disconnected() end
            end)
        end)
    end)
end

function M.lock(manifest, id, lease_socket)
    local dirty = M.dirty(manifest)
    if #dirty > 0 then return { error = 'dirty_buffers', paths = dirty } end
    local lock = locks[id]
    local new = not lock
    if not lock then
        if type(lease_socket) ~= 'string' or lease_socket == '' then return { error = 'invalid_lease' } end
        lock = { id = id, targets = targets_for(manifest), buffers = {}, conflicts = {} }
        locks[id] = lock
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do lock_buffer(lock, buf) end
    local conflicts = vim.tbl_keys(lock.conflicts)
    table.sort(conflicts)
    if #conflicts > 0 then return { error = 'dirty_buffers', paths = conflicts } end
    if new then start_lease(lock, lease_socket) end
    return { ok = true }
end

function M.unlock(id)
    local lock = locks[id]
    if not lock then return { ok = true } end
    close_lease(lock)
    for buf in pairs(lock.buffers) do
        local previous = protected[buf]
        if previous then previous.owners[id] = nil end
        if previous and not next(previous.owners) and vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= '' and canonical(name) == previous.name and not vim.bo[buf].modifiable then
                vim.bo[buf].modifiable = previous.modifiable
            end
        end
        if previous and not next(previous.owners) then protected[buf] = nil end
    end
    locks[id] = nil
    return { ok = true }
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufFilePost' }, {
    callback = function(args)
        for _, lock in pairs(locks) do lock_buffer(lock, args.buf) end
    end,
})

function M.refresh(manifest)
    local targets = {}
    for _, change in ipairs(manifest.changes) do
        targets[canonical(vim.fs.joinpath(manifest.root, change.path))] = change
    end
    local failed = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            local change = name ~= '' and targets[canonical(name)] or nil
            if change then
                local after = value_or_nil(change.after)
                if vim.bo[buf].modified or not after then
                    failed = true
                else
                    local text = vim.base64.decode(after.content_b64)
                    local without_crlf = text:gsub('\r\n', '')
                    local crlf = text:find('\r\n', 1, true) and not without_crlf:find('\n', 1, true)
                    local ok = pcall(vim.api.nvim_buf_call, buf, function()
                        if vim.bo[buf].modified then error('buffer changed before refresh') end
                        vim.cmd('silent edit ++ff=' .. (crlf and 'dos' or 'unix'))
                    end)
                    if not ok then failed = true end
                end
            end
        end
    end
    return failed and { error = 'refresh_failed' } or { ok = true }
end

local function render(value)
    value = value_or_nil(value)
    if not value then return { '' }, 'empty' end
    local text = vim.base64.decode(value.content_b64)
    local has_eol = text:sub(-1) == '\n'
    local without_crlf = text:gsub('\r\n', '')
    local crlf = text:find('\r\n', 1, true) and not without_crlf:find('\n', 1, true)
    local format = crlf and 'CRLF' or (text:find('\r\n', 1, true) and 'mixed-eol' or 'LF')
    if has_eol then text = text:sub(1, -2) end
    local lines = vim.split(text, '\n', { plain = true })
    if crlf then
        for i, line in ipairs(lines) do lines[i] = line:gsub('\r$', '') end
    end
    return lines, format .. ',' .. (has_eol and 'eol' or 'no-eol')
end

local function scratch(review_id, path, side, value)
    local lines, annotation = render(value)
    local buf = vim.api.nvim_create_buf(false, true)
    local ok, err = pcall(function()
        vim.bo[buf].bufhidden = 'hide'
        vim.bo[buf].swapfile = false
        vim.api.nvim_buf_set_name(buf, ('present://%s/%s [%s,%s]'):format(review_id, path, side, annotation))
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        vim.bo[buf].readonly = true
    end)
    if not ok then
        if vim.api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then pcall(vim.api.nvim_buf_delete, buf, {}) end
        error(err)
    end
    return buf
end

local function intact(tab, pair, ticks)
    if not vim.api.nvim_tabpage_is_valid(tab) then return false end
    local windows = vim.api.nvim_tabpage_list_wins(tab)
    if #windows ~= 2 then return false end
    local buffers = {}
    for _, window in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(window)
        if vim.bo[buf].modified then return false end
        buffers[buf] = true
    end
    return buffers[pair[1]] and buffers[pair[2]]
        and vim.api.nvim_buf_get_changedtick(pair[1]) == ticks[1]
        and vim.api.nvim_buf_get_changedtick(pair[2]) == ticks[2]
end

function M.close(id)
    local review = reviews[id]
    if not review then return { skipped = 0 } end
    local original = vim.api.nvim_get_current_tabpage()
    local skipped = 0
    for _, item in ipairs(review.tabs) do
        if vim.api.nvim_tabpage_is_valid(item.tab) then
            if intact(item.tab, item.buffers, item.ticks) then
                vim.api.nvim_set_current_tabpage(item.tab)
                vim.cmd.tabclose()
                for _, buf in ipairs(item.buffers) do
                    if vim.api.nvim_buf_is_valid(buf) and not vim.bo[buf].modified then
                        pcall(vim.api.nvim_buf_delete, buf, {})
                    end
                end
            else
                skipped = skipped + 1
            end
        end
    end
    if vim.api.nvim_tabpage_is_valid(original) then vim.api.nvim_set_current_tabpage(original) end
    if skipped == 0 then reviews[id] = nil end
    return { skipped = skipped }
end

local function send_decision(review, decision)
    if review.pending or review.decided then return end
    review.pending = true
    local pipe = vim.uv.new_pipe(false)
    pipe:connect(review.socket, function(err)
        if err then
            pipe:close()
            vim.schedule(function()
                review.pending = false
                vim.notify('Present: could not send decision: ' .. tostring(err), vim.log.levels.ERROR)
            end)
            return
        end
        pipe:write(vim.json.encode({ id = review.id, decision = decision }) .. '\n', function(write_err)
            pipe:shutdown(function() pipe:close() end)
            vim.schedule(function()
                review.pending = false
                if write_err then
                    vim.notify('Present: could not send decision: ' .. tostring(write_err), vim.log.levels.ERROR)
                else
                    review.decided = true
                    M.close(review.id)
                end
            end)
        end)
    end)
end

vim.api.nvim_create_autocmd('TabClosed', {
    callback = function()
        vim.schedule(function()
            for _, review in pairs(reviews) do
                local any_open = false
                for _, item in ipairs(review.tabs) do
                    if vim.api.nvim_tabpage_is_valid(item.tab) then any_open = true; break end
                end
                if not any_open then send_decision(review, 'cancel') end
            end
        end)
    end,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
        for _, review in pairs(reviews) do
            if not review.pending and not review.decided then
                pcall(function()
                    local channel = vim.fn.sockconnect('pipe', review.socket, { rpc = false })
                    if channel > 0 then
                        vim.fn.chansend(channel, vim.json.encode({ id = review.id, decision = 'cancel' }) .. '\n')
                        vim.fn.chanclose(channel)
                    end
                end)
            end
        end
    end,
})

local function close_partial(review, created)
    local original = vim.api.nvim_get_current_tabpage()
    for _, item in ipairs(review.tabs) do
        if vim.api.nvim_tabpage_is_valid(item.tab) then
            local safe = true
            for _, window in ipairs(vim.api.nvim_tabpage_list_wins(item.tab)) do
                local buf = vim.api.nvim_win_get_buf(window)
                local tick = created[buf]
                if tick then
                    if vim.api.nvim_buf_get_changedtick(buf) ~= tick or vim.bo[buf].modified then safe = false end
                else
                    local elsewhere = false
                    for _, other in ipairs(vim.fn.win_findbuf(buf)) do
                        if vim.api.nvim_win_is_valid(other) and vim.api.nvim_win_get_tabpage(other) ~= item.tab then
                            elsewhere = true
                        end
                    end
                    if not elsewhere then safe = false end
                end
            end
            if safe then
                vim.api.nvim_set_current_tabpage(item.tab)
                pcall(vim.cmd.tabclose)
            end
        end
    end
    for buf, tick in pairs(created) do
        if vim.api.nvim_buf_is_valid(buf) and #vim.fn.win_findbuf(buf) == 0
            and not vim.bo[buf].modified and vim.api.nvim_buf_get_changedtick(buf) == tick then
            pcall(vim.api.nvim_buf_delete, buf, {})
        end
    end
    if vim.api.nvim_tabpage_is_valid(original) then vim.api.nvim_set_current_tabpage(original) end
    reviews[review.id] = nil
end

function M.open(manifest, decision_socket, requested_id, alive)
    local paths = M.dirty(manifest)
    if #paths > 0 then return { error = 'dirty_buffers', paths = paths } end
    sequence = sequence + 1
    local id = requested_id or ('%s-%s'):format(vim.fn.getpid(), sequence)
    if type(id) ~= 'string' or not id:match('^[%w%-]+$') or reviews[id] then
        return { error = 'invalid_review_id' }
    end
    local review = { id = id, socket = decision_socket, tabs = {} }
    reviews[id] = review
    local created = {}
    local ok, err = pcall(function()
        for _, change in ipairs(manifest.changes) do
            if alive and not alive() then error('preview request expired') end
            local left = scratch(id, change.path, 'before', change.before)
            created[left] = vim.api.nvim_buf_get_changedtick(left)
            local right = scratch(id, change.path, 'after', change.after)
            created[right] = vim.api.nvim_buf_get_changedtick(right)
            vim.cmd('tab split')
            local tab = vim.api.nvim_get_current_tabpage()
            table.insert(review.tabs, {
                tab = tab,
                buffers = { left, right },
                ticks = { created[left], created[right] },
            })
            local left_window = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(left_window, left)
            vim.cmd.diffthis()
            vim.cmd('rightbelow vsplit')
            vim.api.nvim_win_set_buf(0, right)
            vim.cmd.diffthis()
            vim.t[tab].present_review = id
            for _, buf in ipairs({ left, right }) do
                vim.keymap.set('n', 'da', function() send_decision(review, 'accept') end,
                    { buffer = buf, desc = 'Accept the whole proposal' })
                vim.keymap.set('n', 'dr', function() send_decision(review, 'reject') end,
                    { buffer = buf, desc = 'Reject the whole proposal' })
            end
        end
        if alive and not alive() then error('preview request expired') end
    end)
    if not ok then
        close_partial(review, created)
        return { error = 'preview_failed', detail = tostring(err) }
    end
    return { id = id, pid = vim.fn.getpid() }
end

return M
