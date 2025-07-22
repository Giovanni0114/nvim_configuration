vim.opt_local.tabstop         = 2
vim.opt_local.shiftwidth      = 2

local checked_checkbox        = "%[x%]"
local unchecked_checkbox      = "%[ %]"

local states                  = {
    ["x"] = "checked",
    [" "] = "unchecked",
    ["="] = "todo",
    ["/"] = "warn",
    ["~"] = "error",
    ["_"] = "abort",
}

local states_icons            = {
    ["checked"]   = "󰱒 ",
    ["unchecked"] = "󰄱 ",
    ["todo"]      = "󰥔 ",
    ["warn"]      = " ",
    ["error"]     = "󰜺 ",
    ["abort"]     = "󰚃 "
}

local state_order             = {
    "checked",
    "unchecked",
    "todo",
    "warn",
    "error",
    "abort"
}

local checkbox_for_state      = function(state)
    for key, value in pairs(states) do
        if value == state then
            return "%[" .. key .. "%]"
        end
    end
    return nil
end

local is_count_complete       = function(count)
    return count["unchecked"] and count["unchecked"] == 0
end

local line_contains_state     = function(line, state)
    local checkbox = checkbox_for_state(state)
    if not checkbox then
        return false
    end
    return line:find("^%s*%- " .. checkbox)
end

local line_contains_unchecked = function(line)
    return line:find(unchecked_checkbox)
end

local line_contains_checked   = function(line)
    return line:find(checked_checkbox)
end

local line_with_checkbox      = function(line)
    return line:find("^%s*- " .. checked_checkbox)
        or line:find("^%s*- " .. unchecked_checkbox)
end

local checkbox                = {
    check = function(line)
        return line:gsub(unchecked_checkbox, checked_checkbox, 1)
    end,

    uncheck = function(line)
        return line:gsub(checked_checkbox, unchecked_checkbox, 1)
    end,

    toggle_check = function(line)
        if line:find(unchecked_checkbox) then
            return line:gsub(unchecked_checkbox, checked_checkbox, 1)
        elseif line:find(checked_checkbox) then
            return line:gsub(checked_checkbox, unchecked_checkbox, 1)
        end
        return line
    end
}


local progress_ns = vim.api.nvim_create_namespace("todo_progress_namespace")

-- Checks if a task is marked as special (e.g., "[/]", "[~]", "[_]").
local function is_marked(line)
    local state = line:match("%[(.)%]")
    for key, value in pairs(states) do
        if state == key then
            return value
        end
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

-- Calculates the indentation level of a list marker (`*`) by counting leading spaces.
-- @param line (string): The line content.
-- @return (number|nil): The indentation level, or nil if not a list item.
local function get_list_item_indent(line)
    if not line then
        return nil
    end
    local indent_str = line:match("^(%s*)[%*%-+]%s")
    if indent_str then
        return #indent_str
    end
    return is_header_line(line)
end


local function get_task_content_start_col(line)
    if not line then
        return nil
    end
    local indent_str = line:match("^(%s*)[%*%-]%s*%[.%]%s")
    if indent_str then
        return #indent_str
    end

    return is_header_line(line)
end

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

    local count = {}
    for key, value in pairs(states) do
        count[value] = 0
    end

    local children_count = 0
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
                local child_count, _ = calculate_progress(lines, ln)
                for key, value in pairs(child_count) do
                    count[key] = count[key] + value
                end
            end
        end
    end

    if children_count > 0 then
        return count, true
    else
        local mark = is_marked(line)
        if mark then
            count[mark] = count[mark] + 1
        end
        return count, false
    end
end

local mark_line_unchecked = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    if not line_with_checkbox(current_line) or line_contains_state(current_line, "unchecked") then
        return
    elseif line_contains_state(current_line, "checked") then
        new_line = checkbox.uncheck(current_line)
    end

    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
end

local mark_line_checked = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    if not line_with_checkbox(current_line) or line_contains_state(current_line, "checked") then
        return
    elseif line_contains_state(current_line, "unchecked") then
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
            local count, has_children = calculate_progress(lines, ln)
            if has_children then
                if is_count_complete(count) then
                    mark_line_checked(bufnr, { ln, 0 })
                else
                    mark_line_unchecked(bufnr, { ln, 0 })
                end

                local sum_count = 0
                for state, value in pairs(count) do
                    if state ~= "abort" then
                        sum_count = sum_count + value
                    end
                end
                progress = sum_count > 0 and count["checked"] / sum_count or 0.0

                local display_text = string.format(" [%.1f%%]", progress * 100)

                for _, key in ipairs(state_order) do
                    if count[key] and count[key] > 0 then
                        display_text = display_text .. string.format(" %s%d", states_icons[key], count[key])
                    end
                end
                display_text = display_text .. " "

                local hl_group = "Comment"
                vim.api.nvim_buf_set_extmark(bufnr, progress_ns, ln - 1, -1, {
                    virt_text = { { display_text, hl_group } },
                    virt_text_pos = "eol",
                })
            end
        end
    end
end

local toggle_line = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    new_line = checkbox.toggle_check(current_line)

    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })

    update_progress()

    if cursor[1] < vim.api.nvim_buf_line_count(bufnr) then
        vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })
    end
end

local cycle_next_char = function(bufnr, cursor)
    local start_line = cursor[1] - 1
    local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

    local new_line = ""

    local current_state = is_marked(current_line)
    local current_character = current_line:match("%[(.)%]")

    if not current_state then
        new_line = current_line
    else
        local next_state_index = nil
        for i, state in ipairs(state_order) do
            if current_state == state then
                next_state_index = (i % #state_order) + 1
                break
            end
        end
        if next_state_index then
            new_line = current_line:gsub(checkbox_for_state(current_state),
                checkbox_for_state(state_order[next_state_index]))
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
    update_progress()
end

--------------------------------------------------------------------------------

-- autocommand to update progress on buffer open
vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "BufWritePost" }, {
    pattern = "*.md",
    callback = update_progress
})

-- Key mappings for toggling checkboxes in markdown files
vim.keymap.set("n", "<C-m>", function()
    local bufnr = vim.api.nvim_buf_get_number(0)
    local cursor = vim.api.nvim_win_get_cursor(0)
    toggle_line(bufnr, cursor)
end, { noremap = true, silent = true, buffer = true })


-- Key mappings for toggling checkboxes in markdown files
vim.keymap.set("n", "<C-\\>", function()
    local bufnr = vim.api.nvim_buf_get_number(0)
    local cursor = vim.api.nvim_win_get_cursor(0)
    cycle_next_char(bufnr, cursor)
end, { noremap = true, silent = true, buffer = true })
