local function warn(file, message)
  vim.schedule(function()
    vim.notify(file .. ': ' .. message .. '; using normal ty environment discovery', vim.log.levels.WARN)
  end)
end

local function find_venv(start_dir)
  -- Start with the launch directory itself, then walk up to the filesystem root.
  for dir in vim.fs.parents(vim.fs.joinpath(start_dir, '.toolchain')) do
    local file = vim.fs.joinpath(dir, '.toolchain')
    local stat = vim.uv.fs_stat(file)
    if stat and stat.type == 'file' then
      local ok, lines = pcall(vim.fn.readfile, file)
      if not ok then
        warn(file, 'could not read toolchain file')
        return
      end

      for _, line in ipairs(lines) do
        local entry = line:match('^%s*ty%s*:%s*(.-)%s*$')
        if entry then
          local path = entry:match('^venv%s+at%s+(.+)$')
          if not path or not (path:sub(1, 1) == '/' or path:sub(1, 2) == '~/') then
            warn(file, 'expected ty: venv at /absolute/path or ~/path')
            return
          end

          local venv = vim.fs.normalize(path, { expand_env = false })
          if vim.fn.executable(vim.fs.joinpath(venv, 'bin', 'python')) == 1 then
            return venv
          end
          warn(file, 'invalid ty venv: ' .. path)
          return
        end
      end
    end
  end
end

return function(start_dir)
  return function(params)
    local venv = find_venv(start_dir)
    if venv then
      params.initializationOptions = vim.tbl_deep_extend('force', params.initializationOptions or {}, {
        configuration = { environment = { python = venv } },
      })
    end
  end
end
