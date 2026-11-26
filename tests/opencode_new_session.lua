-- Run with: nvim --clean --headless -l tests/opencode_new_session.lua
local plugin_dir = vim.fn.stdpath('data') .. '/lazy/opencode.nvim'
vim.opt.runtimepath:prepend(plugin_dir)

local Promise = require('opencode.promise')
local Server = require('opencode.server')
local requests = {}
local notifications = {}
local create_error
local malformed_response = false
local prompt_error
local session_count = 0
local session = {
    id = 'ses_new',
    projectID = 'project',
    cost = 0,
    tokens = { input = 0, output = 0, reasoning = 0, cache = { read = 0, write = 0 } },
    time = { created = 1, updated = 1 },
    location = { directory = vim.fn.getcwd() },
}
local server = setmetatable({}, Server)

function server:curl(path, method, body, resolve, reject)
    requests[#requests + 1] = { path = path, method = method, body = body }
    if path == '/api/session' and method == 'POST' then
        if create_error then return reject(create_error) end
        if malformed_response then return resolve({ data = {} }) end
        session_count = session_count + 1
        resolve({ data = vim.tbl_extend('force', session, { id = 'ses_new_' .. session_count }) })
    elseif path:match('^/api/session%?') and method == 'GET' then
        resolve({ data = { vim.tbl_extend('force', session, { id = 'ses_old' }) } })
    elseif path:match('^/api/session/[^/]+/prompt$') and method == 'POST' then
        if prompt_error then return reject(prompt_error) end
        resolve({ data = {} })
    else
        reject('Unexpected request: ' .. method .. ' ' .. path)
    end
end

package.loaded['opencode.server.discovery'] = {
    get = function() return Promise.resolve(server) end,
}
vim.ui.input = function(_, callback) callback('@this: Explain this') end
vim.notify = function(message, level) notifications[#notifications + 1] = { message = message, level = level } end
vim.cmd.edit('lua/plugins/opencode.lua')
vim.api.nvim_win_set_cursor(0, { 1, 0 })

local spec = dofile('lua/plugins/opencode.lua')
spec.config()
local mapping = vim.fn.maparg('<C-a>', 'n', false, true)
assert(type(mapping.callback) == 'function', 'normal-mode <C-a> mapping is missing')
mapping.callback()
vim.wait(1000, function()
    for _, request in ipairs(requests) do
        if request.path:match('/prompt$') then return true end
    end
    return false
end)

assert(#requests == 2, 'expected a create request and a prompt, got ' .. vim.inspect(requests))
assert(requests[1].method == 'POST' and requests[1].path == '/api/session',
    'expected a new session, got ' .. vim.inspect(requests))
assert(requests[1].body.location.directory == vim.fn.getcwd(), 'new session must use Neovim cwd')
assert(requests[2].path == '/api/session/ses_new_1/prompt', 'prompt must target the newly created session')
assert(requests[2].body.text == 'lua/plugins/opencode.lua:L1:C1: Explain this',
    'prompt must include the current cursor context: ' .. vim.inspect(requests[2].body))
print('PASS: <C-a> creates a session and sends its question there')

requests = {}
local answer
vim.ui.input = function(_, callback) answer = callback end
mapping.callback()
assert(vim.wait(1000, function() return answer ~= nil end), 'question input did not open')
assert(#requests == 0, 'opening the question must not create a session')
answer(nil)
vim.wait(100, function() return false end)
assert(#requests == 0, 'cancelling must not create a session')
assert(#notifications == 0, 'cancelling must not show an error')
print('PASS: cancelling the question does not create a session')

requests = {}
vim.ui.input = function(_, callback) callback('@this: Explain this selection') end
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('gg0v3l<C-a>', true, false, true), 'xt', false)
assert(vim.wait(1000, function() return #requests >= 2 end), 'visual-mode question was not submitted')
assert(requests[2].path == '/api/session/ses_new_2/prompt', 'each question must use a separate session')
assert(requests[2].body.text == 'lua/plugins/opencode.lua:L1:C1-L1:C4: Explain this selection',
    'prompt must include the visual selection: ' .. vim.inspect(requests[2].body))
print('PASS: visual selection is sent to a different new session')

requests = {}
create_error = 'session creation failed'
vim.ui.input = function(_, callback) callback('@this: Explain this') end
mapping.callback()
assert(vim.wait(1000, function() return #notifications > 0 end), 'session creation error was not shown')
assert(#requests == 1 and requests[1].path == '/api/session', 'a failed creation must not send a prompt')
assert(notifications[1].message == create_error and notifications[1].level == vim.log.levels.ERROR,
    'session creation error must be reported')
print('PASS: session creation failure is reported without sending a prompt')

requests = {}
notifications = {}
create_error = nil
malformed_response = true
mapping.callback()
assert(vim.wait(1000, function() return #notifications > 0 end), 'invalid session response was not reported')
assert(#requests == 1, 'an invalid session response must not send a prompt')
assert(notifications[1].message == 'Failed to create OpenCode session', 'invalid session response must be reported')
print('PASS: invalid session response is reported without sending a prompt')

requests = {}
notifications = {}
malformed_response = false
prompt_error = 'prompt failed'
mapping.callback()
assert(vim.wait(1000, function() return #notifications > 0 end), 'prompt failure was not reported')
assert(#requests == 2 and requests[2].path == '/api/session/ses_new_3/prompt',
    'prompt failure must occur in the new session')
assert(notifications[1].message == prompt_error and notifications[1].level == vim.log.levels.ERROR,
    'prompt failure must be reported')
print('PASS: prompt failure is reported')
