vim.api.nvim_create_user_command("MarkdownFolds", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  vim.opt_local.foldmethod = "manual"
  -- clear existing folds
  vim.cmd("normal! zE")

  local stack = {}

  local function header_level(line)
    local hashes = line:match("^(#+)%s+")
    return hashes and #hashes or nil
  end

  local function create_fold(start_line, end_line)
    -- safety: must have content below header
    if end_line > start_line then
      vim.cmd(string.format("%d,%dfold", start_line, end_line))
    end
  end

  for i, line in ipairs(lines) do
    local level = header_level(line)

    -- --- acts as hard fold boundary
    if line:match("^%-%-%-$") then
      while #stack > 0 do
        local top = table.remove(stack)
        create_fold(top.start_line, i - 1)
      end
    end

    if level then
      -- close same or higher-level sections
      while #stack > 0 and stack[#stack].level >= level do
        local top = table.remove(stack)

        local end_line = i - 2
        if end_line < top.start_line then
          end_line = i - 1
        end

        create_fold(top.start_line, end_line)
      end

      -- IMPORTANT: fold starts AFTER header line
      table.insert(stack, {
        level = level,
        start_line = i + 1,
      })
    end
  end

  -- close remaining folds
  while #stack > 0 do
    local top = table.remove(stack)
    create_fold(top.start_line, #lines)
  end

end, {})
