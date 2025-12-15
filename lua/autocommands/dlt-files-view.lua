vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.dlt",
    callback = function(args)
        local filepath = args.file

        -- make temporary file
        -- local converted_file = vim.fn.tempname() .. ".log"

        -- replace .dlt to .converted.log
        local converted_file = filepath:gsub("%.dlt$", ".converted.log")

        -- check if exists
        if vim.fn.filereadable(converted_file) == 1 then
            -- Edit the existing converted file
            vim.cmd("bdelete")  -- Close the original DLT buffer
            vim.cmd("edit " .. vim.fn.fnameescape(converted_file))
            vim.notify("Convertes DLT" .. converted_file .. " already exists", vim.log.levels.INFO)
            return
        end

        local cmd = string.format("dlt-viewer -c %q %q", filepath, converted_file)

        -- Notify user (optional)
        vim.notify("Converting DLT to text...", vim.log.levels.INFO)

        -- Run conversion synchronously
        local success = os.execute(cmd)

        if success then
            vim.cmd("bdelete")  -- Close the original DLT buffer
            vim.cmd("edit " .. vim.fn.fnameescape(converted_file))
        else
            vim.notify("DLT conversion failed: " .. cmd, vim.log.levels.ERROR)
        end
    end,
})
