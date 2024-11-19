-- Telescope picker for custom commands
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

-- Define custom commands
local obsidian_commands = {
    { name = "Open",           cmd = "ObsidianOpen" },
    { name = "New",            cmd = "ObsidianNew" },
    { name = "QuickSwitch",    cmd = "ObsidianQuickSwitch" },
    { name = "FollowLink",     cmd = "ObsidianFollowLink" },
    { name = "Backlinks",      cmd = "ObsidianBacklinks" },
    { name = "Tags",           cmd = "ObsidianTags" },
    { name = "Today",          cmd = "ObsidianToday" },
    { name = "Yesterday",      cmd = "ObsidianYesterday" },
    { name = "Tomorrow",       cmd = "ObsidianTomorrow" },
    { name = "Dailies",        cmd = "ObsidianDailies" },
    { name = "Template",       cmd = "ObsidianTemplate" },
    { name = "Search",         cmd = "ObsidianSearch" },
    { name = "Link",           cmd = "ObsidianLink" },
    { name = "LinkNew",        cmd = "ObsidianLinkNew" },
    { name = "Links",          cmd = "ObsidianLinks" },
    { name = "ExtractNote",    cmd = "ObsidianExtractNote" },
    { name = "Workspace",      cmd = "ObsidianWorkspace" },
    { name = "PasteImg",       cmd = "ObsidianPasteImg" },
    { name = "Rename",         cmd = "ObsidianRename" },
    { name = "ToggleCheckbox", cmd = "ObsidianToggleCheckbox" },
}

local function run_obsidian_command(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.cmd(selection.cmd)
end

function ObsidianCommandsPicker()
    pickers.new({}, {
        prompt_title = 'Obsidian Commands',
        finder = finders.new_table {
            results = obsidian_commands,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.name,
                    ordinal = entry.name,
                    cmd = entry.cmd,
                }
            end
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(_, map)
            map('i', '<CR>', run_obsidian_command)
            map('n', '<CR>', run_obsidian_command)
            return true
        end,
    }):find()
end

vim.api.nvim_set_keymap('n', '<leader>to', ':lua ObsidianCommandsPicker()<CR>', { noremap = true, silent = true })
