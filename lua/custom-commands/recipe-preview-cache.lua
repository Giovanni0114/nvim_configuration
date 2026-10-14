local RecipePreviewCache = {}
RecipePreviewCache.__index = RecipePreviewCache

function RecipePreviewCache.start_recipe_preview(recipe, callback)
    return vim.system({ 'just', '--show', recipe }, { text = true }, function(result)
        local lines
        if result.code == 0 then
            lines = vim.split(result.stdout, '\n', { plain = true })
            if lines[#lines] == '' then
                table.remove(lines)
            end
        else
            lines = { 'Could not show recipe: ' .. recipe }
        end

        vim.schedule(function()
            callback(lines)
        end)
    end)
end

function RecipePreviewCache.new(recipes, start_job, max_concurrent, on_complete)
    return setmetatable({
        recipes = recipes,
        start_job = start_job,
        max_concurrent = max_concurrent or 2,
        next_recipe = 1,
        running = 0,
        previews = {},
        active_jobs = {},
        on_complete = on_complete,
    }, RecipePreviewCache)
end

function RecipePreviewCache:get(recipe)
    return self.previews[recipe]
end

function RecipePreviewCache:preload()
    if self.disposed then
        return
    end

    while self.running < self.max_concurrent and self.next_recipe <= #self.recipes do
        local recipe = self.recipes[self.next_recipe]
        self.next_recipe = self.next_recipe + 1
        self.running = self.running + 1
        local finished = false

        local job = self.start_job(recipe, function(lines)
            finished = true
            self.active_jobs[recipe] = nil
            if self.disposed then
                return
            end

            self.previews[recipe] = lines
            self.running = self.running - 1
            if self.on_complete then
                self.on_complete(recipe, lines)
            end
            self:preload()
        end)

        if self.disposed then
            if job and job.kill then
                job:kill(15)
            end
        elseif not finished and job then
            self.active_jobs[recipe] = job
        end
    end
end

function RecipePreviewCache:dispose()
    self.disposed = true
    self.previews = {}

    for _, job in pairs(self.active_jobs) do
        job:kill(15)
    end
    self.active_jobs = {}
end

return RecipePreviewCache
