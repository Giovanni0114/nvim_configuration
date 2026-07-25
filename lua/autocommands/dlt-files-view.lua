vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.dlt",
    callback = function(args)
        local filepath = args.file
        local converted_file = filepath:gsub("%.dlt$", ".converted.log")

        if vim.fn.filereadable(converted_file) == 1 then
            vim.cmd("bdelete")
            vim.cmd("edit " .. vim.fn.fnameescape(converted_file))
            vim.notify("Convertes DLT" .. converted_file .. " already exists", vim.log.levels.INFO)
            return
        end

        local cmd = string.format("dlt-viewer -c %q %q", filepath, converted_file)

        vim.notify("Converting DLT to text...", vim.log.levels.INFO)

        local success = os.execute(cmd)

        if success then
            vim.cmd("bdelete")
            vim.cmd("edit " .. vim.fn.fnameescape(converted_file))
        else
            vim.notify("DLT conversion failed: " .. cmd, vim.log.levels.ERROR)
        end
    end,
})
