local function get_recipes()
    local output = vim.fn.systemlist({ 'just', '--summary', '--unsorted' })

    if vim.v.shell_error ~= 0 then
        vim.notify(
            'just: ' .. table.concat(output, '\n'),
            vim.log.levels.ERROR,
            { title = 'Just' }
        )
        return nil
    end

    local recipes = {}
    for _, line in ipairs(output) do
        for recipe in line:gmatch('%S+') do
            table.insert(recipes, recipe)
        end
    end

    return recipes
end

local function run_recipe(choice)
    if not choice then
        return
    end
    vim.cmd('wa')
    vim.cmd('make! ' .. choice)
end

local function just_pick_and_run()
    local recipes = get_recipes()
    if not recipes then
        return
    end
    if vim.tbl_isempty(recipes) then
        vim.notify('No just recipes found', vim.log.levels.WARN, { title = 'Just' })
        return
    end

    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local previewers = require('telescope.previewers')
    local RecipePreviewCache = require('custom-commands.recipe-preview-cache')

    local previewer
    local previews = RecipePreviewCache.new(recipes, RecipePreviewCache.start_recipe_preview, 2, function(recipe, lines)
        if previewer and previewer.state and previewer.state.bufname == recipe then
            local bufnr = previewer.state.bufnr
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
                vim.bo[bufnr].filetype = 'just'
            end
        end
    end)

    previewer = previewers.new_buffer_previewer {
        title = 'Recipe',
        teardown = function()
            previews:dispose()
        end,
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry)
            local lines = previews:get(entry.value) or { 'Loading recipe: ' .. entry.value }
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.bo[self.state.bufnr].filetype = 'just'
        end,
    }

    previews:preload()

    pickers.new({}, {
        prompt_title = 'Just recipes',
        finder = finders.new_table { results = recipes },
        sorter = conf.generic_sorter {},
        previewer = previewer,
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    run_recipe(selection[1])
                end
            end)
            return true
        end,
    }):find()
end

vim.api.nvim_create_user_command('JustPick', just_pick_and_run, {})
vim.keymap.set('n', '<leader>tj', just_pick_and_run, { desc = 'Pick and run a just recipe' })
