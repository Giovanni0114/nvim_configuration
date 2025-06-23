local checked_character = "x"

local checked_checkbox = "%[" .. checked_character .. "%]"
local unchecked_checkbox = "%[ %]"

-- checkbock may also contains a characters / and ~ and script should ignore such lines
local line_contains_a_checked_checkbox = function(line)
    return line:find(checked_checkbox)
end

local line_contains_unchecked = function(line)
    return line:find(unchecked_checkbox)
end

local line_contains_checked = function(line)
    return line:find(checked_checkbox)
end

local line_with_checkbox = function(line)
    -- return not line_contains_a_checked_checkbox(line) and not line_contains_an_unchecked_checkbox(line)
    return line:find("^%s*- " .. checked_checkbox)
        or line:find("^%s*- " .. unchecked_checkbox)
        or line:find("^%s*%d%. " .. checked_checkbox)
        or line:find("^%s*%d%. " .. unchecked_checkbox)
end

local checkbox = {
    check = function(line)
        return line:gsub(unchecked_checkbox, checked_checkbox, 1)
    end,

    uncheck = function(line)
        return line:gsub(checked_checkbox, unchecked_checkbox, 1)
    end,

    make_checkbox = function(line)
        if not line:match("^%s*-%s.*$") and not line:match("^%s*%d%s.*$") then
            -- "xxx" -> "- [ ] xxx"
            return line:gsub("(%S+)", "- [ ] %1", 1)
        else
            -- "- xxx" -> "- [ ] xxx", "3. xxx" -> "3. [ ] xxx"
            return line:gsub("(%s*- )(.*)", "%1[ ] %2", 1):gsub("(%s*%d%. )(.*)", "%1[ ] %2", 1)
        end
    end,
}


local progress_ns = vim.api.nvim_create_namespace("todo_progress_namespace")

-- Checks if a task is marked as done (e.g., "[x]").
-- @param line (string): The line content.
-- @return (boolean|nil): True if done, false if not, nil if not a valid task checkbox.
local function is_marked_done(line)
    local state = line:match("%[(.)%]")
    if state == "x" then
        return true
    elseif state == "_" then
        return true
    elseif state == " " then
        return false
    end
    return nil
end

local function is_header_line(line)
    if not line then
        return nil
    end
    -- Matches headers: "# ", "## ", "### ", etc.
    local indent_str = line:match("^(#+)")
    if indent_str then
        return -1
    end

    return nil
end

-- Calculates the indentation level of a list marker (`*`, `1.`, etc.) by counting leading spaces.
-- @param line (string): The line content.
-- @return (number|nil): The indentation level, or nil if not a list item.
local function get_list_item_indent(line)
    if not line then
        return nil
    end
    -- Matches both ordered and unordered list markers at the start of the line.
    local indent_str = line:match("^(%s*)[%*%-+]%s") or line:match("^(%s*)%d+[.%)%)]%s")
    if indent_str then
        return #indent_str
    end
    return is_header_line(line)
end

-- Finds the starting column of the text content in a plain markdown list item.
-- @param line (string): The line content.
-- @return (number|nil): The 1-based column number, or nil if not a list item.
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

    return is_header_line(line)
end

-- Recursively calculates progress and counts incomplete items for a task.
-- @param lines (table): The buffer lines.
-- @param start_ln (number): The 1-based line number of the task to analyze.
-- @return (number, boolean, number): A tuple with progress (0.0-1.0), a boolean for has_children, and the count of incomplete sub-tasks.
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

local mark_line_unchecked = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    if not line_with_checkbox(current_line) or line_contains_unchecked(current_line) then
        return
    elseif line_contains_checked(current_line) then
        new_line = checkbox.uncheck(current_line)
    end

    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
end

local mark_line_checked = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    if not line_with_checkbox(current_line) or line_contains_checked(current_line) then
        return
    elseif line_contains_unchecked(current_line) then
        new_line = checkbox.check(current_line)
    end

    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
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
                local display_text = string.format(" [ 󰱒 %.1f%% ] ", progress * 100)
                local hl_group = "Comment"
                vim.api.nvim_buf_set_extmark(bufnr, progress_ns, ln - 1, -1, {
                    virt_text = { { display_text, hl_group } },
                    virt_text_pos = "eol",
                })
            end
        end
    end
end

local validate_progress = function()
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
                if progress == 1.0 then
                    mark_line_checked(bufnr, { ln, 0 })
                else
                    mark_line_unchecked(bufnr, { ln, 0 })
                end
            end
        end
    end
end

local toggle_line = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    if not line_with_checkbox(current_line) then
        -- new_line = checkbox.make_checkbox(current_line)
        return
    elseif line_contains_unchecked(current_line) then
        new_line = checkbox.check(current_line)
    elseif line_contains_checked(current_line) then
        new_line = checkbox.uncheck(current_line)
    end

    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
    vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })

    validate_progress()
    update_progress()
end

--------------------------------------------------------------------------------

-- Key mappings for toggling checkboxes in markdown files
vim.keymap.set("n", "<C-m>", function()
    local bufnr = vim.api.nvim_buf_get_number(0)
    local cursor = vim.api.nvim_win_get_cursor(0)
    toggle_line(bufnr, cursor)
end, { noremap = true, silent = true })

-- autocommand to update progress on buffer open
vim.api.nvim_create_autocmd({ "BufReadPost", "TextChangedI", "InsertLeave" }, {
    pattern = "*.md",
    callback = function()
        validate_progress()
        update_progress()
    end,
})
