local progress_ns = vim.api.nvim_create_namespace("todo_progress_namespace")

---
-- Checks if a task is marked as done (e.g., "[x]").
-- @param line (string): The line content.
-- @return (boolean|nil): True if done, false if not, nil if not a valid task checkbox.
--
local function is_marked_done(line)
    local state = line:match("%[(.)%]")
    if state == "x" then
        return true
    elseif state == " " then
        return false
    end
    return nil
end

---
-- Calculates the indentation level of a list marker (`*`, `1.`, etc.) by counting leading spaces.
-- @param line (string): The line content.
-- @return (number|nil): The indentation level, or nil if not a list item.
--
local function get_list_item_indent(line)
    if not line then
        return nil
    end
    -- Matches both ordered and unordered list markers at the start of the line.
    local indent_str = line:match("^(%s*)[%*%-+]%s") or line:match("^(%s*)%d+[.%)%)]%s")
    if indent_str then
        return #indent_str
    end
    return nil
end

---
-- Finds the starting column of the text content in a plain markdown list item.
-- @param line (string): The line content.
-- @return (number|nil): The 1-based column number, or nil if not a list item.
--
local function get_list_marker_info(line)
    if not line then
        return nil
    end
    local _, match_end = line:find("^%s*[%*%-+]%s+") -- Unordered
    if match_end then
        return match_end + 1
    end
    _, match_end = line:find("^%s*%d+[.%)%)]%s+") -- Ordered
    if match_end then
        return match_end + 1
    end
    return nil
end


local function get_task_content_start_col(line)
    if not line then
        return nil
    end
    -- Matches unordered lists: "* [ ]"
    local indent_str = line:match("^(%s*)[%*%-+]%s*%[.%]%s")
    if indent_str then
        return #indent_str
    end
    -- Matches ordered lists: "1. [ ]"
    indent_str = line:match("^(%s*)%d+[.%)%)]%s*%[.%]%s")
    if indent_str then
        return #indent_str
    end
    return nil
end

local function get_list_marker_info(line)
    if not line then
        return nil
    end
    local _, match_end = line:find("^%s*[%*%-+]%s+") -- Unordered
    if match_end then
        return match_end + 1
    end
    _, match_end = line:find("^%s*%d+[.%)%)]%s+") -- Ordered
    if match_end then
        return match_end + 1
    end
    return nil
end


local function get_task_content_start_col(line)
    if not line then
        return nil
    end
    -- Matches unordered lists: "* [ ]"
    local indent_str = line:match("^(%s*)[%*%-]%s*%[.%]%s")
    if indent_str then
        return #indent_str
    end

    return nil
end

---
-- Recursively calculates progress and counts incomplete items for a task.
-- @param lines (table): The buffer lines.
-- @param start_ln (number): The 1-based line number of the task to analyze.
-- @return (number, boolean, number): A tuple with progress (0.0-1.0), a boolean for has_children, and the count of incomplete sub-tasks.
--
local function calculate_progress(lines, start_ln)
    local line = lines[start_ln]
    if not line then
        return 0, false, 0
    end

    local parent_bound = get_task_content_start_col(line)
    if not parent_bound then
        return 0, false, 0
    end
    local parent_indent = get_list_item_indent(line)
    if not parent_indent then
        return 0, false, 0
    end

    local children_progress_total = 0
    local children_count = 0
    local total_incomplete_count = 0
    local direct_child_bound = nil

    for ln = start_ln + 1, #lines do
        local child_line = lines[ln]
        local child_indent = get_list_item_indent(child_line)

        if child_indent and child_indent <= parent_indent then
            break
        end

        local child_bound = get_task_content_start_col(child_line)
        if child_bound then
            if not direct_child_bound then
                direct_child_bound = child_bound
            end

            if child_bound == direct_child_bound then
                children_count = children_count + 1
                local child_progress, _, child_incomplete = calculate_progress(lines, ln)
                children_progress_total = children_progress_total + child_progress
                total_incomplete_count = total_incomplete_count + child_incomplete
            end
        end
    end

    if children_count > 0 then
        return children_progress_total / children_count, true, total_incomplete_count
    else
        local done = is_marked_done(line)
        return done and 1.0 or 0.0, false, done and 0 or 1
    end
end


local update_progress = function()
    local bufnr = vim.api.nvim_get_current_buf()
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- If no tasks exist in the file, skip the rest of the checking
    local content = table.concat(lines, "\n")
    if not content:match("%[%s%]") and not content:match("%[x%]") then
        vim.api.nvim_buf_clear_namespace(bufnr, progress_ns, 0, -1)
        return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, progress_ns, 0, -1)

    for ln = 1, #lines do
        local line = lines[ln]
        if get_task_content_start_col(line) then
            local progress, has_children, incomplete_count = calculate_progress(lines, ln)
            if has_children then
                local display_text = string.format(" [ %.1f%% ]", progress * 100)
                local hl_group = "Comment"
                vim.api.nvim_buf_set_extmark(bufnr, progress_ns, ln - 1, -1, {
                    virt_text = { { display_text, hl_group } },
                    virt_text_pos = "eol",
                })
            end
        end
    end
end

local todo_progress = vim.api.nvim_create_augroup("todo_progress", { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    desc = "Update todo progress in virtual text after editing",
    group = todo_progress,
    callback = update_progress,
})
