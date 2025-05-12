require "mappings.git-mappings"
require "mappings.vimgrep-search"
require "mappings.telescope"
require "mappings.markdown-mappings"
require "mappings.lsp-mappings"

-- Utils

-- vim.keymap.set("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text" })
vim.keymap.set("x", "gp", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text" })

vim.cmd [[nnoremap # <Cmd>let @/='\<'.expand('<cword>').'\>'<bar>set hlsearch<CR>]]
vim.cmd [[nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "remove hightlight selection" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Moving indents [gv - select previous visual selection]
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- Buffers
vim.keymap.set('n', '<A-c>', '<C-^>')
vim.keymap.set("n", "<A-S-c>", "<cmd>bdelete!<CR>")

vim.keymap.set('n', '<A-S-.>', '<cmd>cn<CR>')
vim.keymap.set('n', '<A-S-,>', '<cmd>cp<CR>')

vim.keymap.set("n", "<A-.>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<A-,>", "<cmd>bprevious<CR>")

-- Explore
vim.keymap.set('n', '<leader>e', '<cmd>Explore<CR>')

-- Windows

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-Left>', '<C-w><C-h>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-Right>', '<C-w><C-l>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-Down>', '<C-w><C-j>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-Up>', '<C-w><C-k>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<A-Up>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Down>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Left>', ':vertical resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Right>', ':vertical resize -2<CR>', { noremap = true, silent = true })


local function find_corresponding_file()
  local current = vim.api.nvim_buf_get_name(0)
  local filename = vim.fn.fnamemodify(current, ":t") -- Just the filename

  -- Check if the file is a .cpp or .hpp filename
  if not filename:match("%.cpp$") and not filename:match("%.hpp$") then
    print("Not a .cpp or .hpp file")
    return
  end

  local root = vim.fn.getcwd()
  local base = filename:gsub("%.[ch]pp$", "")
  local target_ext = filename:match("%.cpp$") and "hpp" or "cpp"
  local target_name = base .. "." .. target_ext

  -- Check if it's already open in another buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local bufname = vim.api.nvim_buf_get_name(buf)
      if vim.fn.fnamemodify(bufname, ":t") == target_name then
        vim.api.nvim_set_current_buf(buf)
        return
      end
    end
  end

  -- Use 'fd' or 'find' to locate the file in project
  local cmd = string.format("find %q -type f -name %q -print -quit", root, target_name)
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
