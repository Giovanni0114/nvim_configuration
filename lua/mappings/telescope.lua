local builtin = require('telescope.builtin')
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

local buffer_searcher = function()
    builtin.buffers {
        attach_mappings = function(prompt_bufnr, map)
            local refresh_buffer_searcher = function()
                actions.close(prompt_bufnr)
                vim.schedule(buffer_searcher)
            end
            local delete_buf = function()
                local selection = action_state.get_selected_entry()
                vim.api.nvim_buf_delete(selection.bufnr, { force = true })
                refresh_buffer_searcher()
            end
            local delete_multiple_buf = function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selection = picker:get_multi_selection()
                for _, entry in ipairs(selection) do
                    vim.api.nvim_buf_delete(entry.bufnr, { force = true })
                end
                refresh_buffer_searcher()
            end
            map('n', 'dd', delete_buf)
            map('n', '<C-d>', delete_multiple_buf)
            map('i', '<C-d>', delete_multiple_buf)
            return true
        end
    }
end

vim.keymap.set('n', '<leader><leader>', buffer_searcher, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>t.', builtin.oldfiles, { desc = '[T]elescope Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>ta', builtin.find_files, { desc = '[T]elescope All Files' })
vim.keymap.set('n', '<leader>tf', builtin.git_files, { desc = '[T]elescope [F]iles (only git scope)' })
vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = '[T]elescope by [G]rep' })
vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = '[T]elescope [H]elp' })
vim.keymap.set('n', '<leader>tj', builtin.jumplist, { desc = '[T]elescope [J]umplist)' })
vim.keymap.set('n', '<leader>tk', builtin.keymaps, { desc = '[T]elescope [K]eymaps' })
vim.keymap.set('n', '<leader>tm', builtin.marks, { desc = '[T]elescope [M]arks)' })
vim.keymap.set('n', '<leader>tr', builtin.lsp_references, { desc = '[T]elescope [R]esume' })
vim.keymap.set('n', '<leader>ts', builtin.builtin, { desc = '[T]elescope [S]elect Telescope' })
vim.keymap.set('n', '<leader>tw', builtin.grep_string, { desc = '[T]elescope current [W]ord' })


vim.keymap.set('n', '<leader>t/', function()
    builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    }
end, { desc = '[T]elescope [/] in Open Files' })

-- Shortcut for searching neovim configuration files
vim.keymap.set('n', '<leader>nn', function()
    builtin.find_files { cwd = vim.fn.stdpath('config') }
end, { desc = '[N]eovim files' })

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values
local Job = require('plenary.job')

-- Convert a single line returned by `cppman -f` into a Telescope entry.  The
-- value, display and ordinal fields all hold the page name.  See
-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md
-- for details on entry makers.
function entry_maker(line)
    return {
        value = line,
        display = line,
        ordinal = line,
    }
end

--- Previewer: runs `cppman <entry>` and feeds the output to Telescope's
-- internal buffer.  The preview is useful to quickly glance at the first
-- couple of lines of a manual page while browsing results.  If `cppman`
-- isn't available on the system the preview will silently fail.
function cppman_previewer()
    return nil

    -- previewers.new_job(function(entry)
    --     -- Only attempt to preview when a value exists.  The entry argument is
    --     -- typically a table from the finder and will contain a `value` field.
    --     if not entry or not entry.value or entry.value == '' then
    --         return nil
    --     end
    --     return { 'cppman', entry.value }
    -- end, {
    --     -- Use the default previewer settings from Telescope.  This setting
    --     -- ensures lines longer than the preview window wrap properly.
    --     title = 'cppman preview',
    -- })
end

--- Open a manual page in a new scratch buffer.  This function is used
-- internally when the user selects an entry from the picker and can also
-- be called directly via the exposed API.  It spawns `cppman` and loads
-- the resulting lines into a new buffer; if an error occurs the user is
-- notified with `vim.notify`.
-- @param page string: the page name, e.g. `std::cout` or `vector::insert`.
function open_page(page)
    if not page or page == '' then
        vim.notify('[cppman] No page provided', vim.log.levels.ERROR)
        return
    end
    -- Run `cppman <page>` and capture its output.  Vim's `systemlist` takes
    -- either a string or a table; here we concatenate the arguments for
    -- maximum portability.  If cppman is unavailable the command will
    -- return an empty list and `systemlist` will raise an error which we
    -- pcall.
    --
    local page_width = vim.fn.getwininfo(vim.fn.win_getid())[1].width - 20
	local cmd = string.format("cppman --force-columns %s '%s'", page_width, page)

    local ok, lines = pcall(vim.fn.systemlist, cmd)
    if not ok then
        vim.notify('[cppman] Failed to call cppman: ' .. tostring(lines), vim.log.levels.ERROR)
        return
    end
    if #lines == 0 then
        vim.notify('[cppman] No output from cppman for ' .. page, vim.log.levels.WARN)
        return
    end
    -- Create a scratch buffer and populate it with the lines from cppman.
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    -- Set the buffer filetype to `man` to reuse Neovim's built‑in man syntax.
    vim.api.nvim_buf_set_option(buf, 'filetype', 'man')
    -- Open the buffer in a new split.  Users can change this call to
    -- `vsplit` or `tabnew` to suit their preferences.
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, buf)
    -- Make the buffer read‑only so accidental edits are prevented.  The user
    -- can always `:bd` to close it.
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

--- Launch a Telescope picker that searches cppman.  Typing in the prompt
-- will call `cppman -f <input>` to find possible manual pages.  Selecting
-- an entry will open the page via `M.open_page` above.  The previewer
-- shows a preview of the currently highlighted page.  You can bind this
-- function to a key mapping like `<leader>cp`.
-- @param opts table: optional Telescope configuration overrides
function search(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = 'cppman search',
        finder = require('telescope.finders').new_job(function(prompt)
            -- Only run the search when a prompt is provided.  Returning nil
            -- suppresses running the job and results in an empty list.
            if not prompt or prompt == '' then
                return nil
            end
            return { 'cppman', '-f', prompt }
        end, entry_maker, _, opts),
        sorter = conf.generic_sorter(opts),
        previewer = cppman_previewer(),
        attach_mappings = function(prompt_bufnr, map)
            -- When the user presses <CR> (select_default) on a result, close the
            -- picker and open the selected page in a new buffer.
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    M.open_page(selection.value)
                end
            end)
            return true
        end,
    }):find()
end
function mysplit (inputstr, sep)
   -- if sep is null, set it as space
   if sep == nil then
      sep = '%s'
   end
   -- define an array
   local t={}
   -- split string based on sep   
   for str in string.gmatch(inputstr, '([^'..sep..']+)') 
   do
      -- insert the substring in table
      table.insert(t, str)
   end
   -- return the array
   return t
end
--- Setup function to register the Telescope extension and create a `:Cppman`
-- command.  You should call this from your Neovim configuration after
-- loading Telescope.  For example:
--
--     require('cppman_telescope').setup()
--
-- After running setup you can call `:Cppman <name>` to open a page
-- directly or use `Telescope cppman` to search.  See the README for
-- additional keybinding examples.
local function setup()
    -- Register the extension with Telescope.  This adds a new picker that
    -- appears under the name `cppman`, so you can run `:Telescope cppman`.
    require('telescope').register_extension({
        exports = {
            cppman = search,
        },
    })
    -- Register a user command that opens a page directly.  Completion for
    -- this command uses cppman -f to offer potential matches.
    vim.api.nvim_create_user_command('Cppman', function(params)
        open_page(params.args)
    end, {
        nargs = 1,
        complete = function(arglead, _, _)
            -- Use cppman -f for completion suggestions.  Running this
            -- synchronously is acceptable because completion happens rarely.
            local results = {}
            local lead = vim.trim(arglead)
            if lead == '' then
                lead = 'std'
            end
            local ok, lines = pcall(vim.fn.systemlist, 'cppman -f ' .. lead)
            if ok then
                for _, line in ipairs(lines) do
                    -- split the line on '-' character
                    line = vim.trim(vim.split(line, '-')[1])
                    table.insert(results, line)
                end
            end
            return results
        end,
    })
end


setup()

vim.keymap.set('n', '<leader>cs', search, { desc = 'cppman search (Telescope)' })
vim.keymap.set('n', 'K', function()
    open_page(vim.fn.expand('<cword>'))
end, { desc = 'cppman open current word' })
