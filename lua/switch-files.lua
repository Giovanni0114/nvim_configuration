local function find_corresponding_file()
  local current = vim.api.nvim_buf_get_name(0)
  local filename = vim.fn.fnamemodify(current, ":t") -- Just the filename

  local base = nil
  if filename:match("%.cpp$") or filename:match("%.c$") then
    base = filename:gsub("%.[cp]+$", "")
    target_ext = "h"
  elseif filename:match("%.hpp$") or filename:match("%.h$") then
    base = filename:gsub("%.[hp]+$", "")
    target_ext = "c"
  else
    print("Not a .cpp or .hpp file")
    return
  end

  local target_name = base .. "." .. target_ext
  local target_name_pp = base .. "." .. target_ext .. "pp"

  print("Searching for: " .. target_name .. " or " .. target_name_pp)
  -- Check if it's already open in another buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local bufname = vim.api.nvim_buf_get_name(buf)
      if vim.fn.fnamemodify(bufname, ":t") == target_name then
        vim.api.nvim_set_current_buf(buf)
        return
      end

      if vim.fn.fnamemodify(bufname, ":t") == target_name_pp then
        vim.api.nvim_set_current_buf(buf)
        return
      end
    end
  end

  local cmd = string.format("find %q -type f \\( -name %q -or -name %q \\) -print -quit", vim.fn.getcwd(), target_name, target_name_pp)
  local handle = io.popen(cmd)
  if not handle then
    print("Unable to run search command")
    return
  end

  local result = handle:read("*l")
  handle:close()

  if result and result ~= "" then
    vim.cmd("edit " .. result)
  else
    print("Corresponding file not found: " .. target_name)
  end
end

vim.keymap.set("n", "<leader>ss", find_corresponding_file, { desc = "Toggle .cpp/.hpp" })
