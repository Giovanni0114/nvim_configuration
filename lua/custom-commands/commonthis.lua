vim.api.nvim_create_user_command("Commonthis", function(opts)
    local commons_dir = "/tmp/commons"
    local current_file = vim.api.nvim_buf_get_name(0)

    if current_file == "" then
        vim.notify("No file is currently open", vim.log.levels.ERROR)
        return
    end

    vim.fn.mkdir(commons_dir, "p")

    local filename
    if opts.args ~= "" then
        filename = opts.args
    else
        filename = vim.fn.fnamemodify(current_file, ":t")
    end

    local dest_path = commons_dir .. "/" .. filename

    local file_exists = vim.fn.filereadable(dest_path) == 1
    if not file_exists then
        local stat_result = vim.fn.system("test -e '" .. dest_path .. "' || test -L '" .. dest_path .. "'")
        file_exists = vim.v.shell_error == 0
    end

    if file_exists then
        if opts.bang then
            vim.fn.system("rm -f '" .. dest_path .. "'")
            vim.notify("Removing existing file at " .. dest_path, vim.log.levels.INFO)
        else
            local choice = vim.fn.confirm("File " .. filename .. " already exists. Overwrite?", "&Yes\n&No", 2)
            if choice ~= 1 then
                return
            end
            vim.fn.system("rm -f '" .. dest_path .. "'")
        end
    end

    local result = vim.fn.system(string.format("ln -s '%s' '%s'", current_file, dest_path))

    if vim.v.shell_error == 0 then
        vim.notify("Symlink created at " .. dest_path, vim.log.levels.INFO)
    else
        vim.notify("Error creating symlink: " .. result, vim.log.levels.ERROR)
    end
end, { nargs = "?", bang = true })
