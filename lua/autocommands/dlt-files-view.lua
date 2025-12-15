vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.dlt",
    callback = function(args)
        local filepath = args.file

        -- make temporary file
        -- local converted_file = vim.fn.tempname() .. ".log"

        -- replace .dlt to .converted.log
        local converted_file = filepath:gsub("%.dlt$", ".converted.log")

        local cmd = string.format("dlt-viewer -c %q %q", filepath, converted_file)

        -- Notify user (optional)
        vim.notify("Converting DLT to text...", vim.log.levels.INFO)

        -- Run conversion synchronously
        local success = os.execute(cmd)

        if success then
            -- Edit the generated temp file instead
            vim.cmd("edit " .. vim.fn.fnameescape(converted_file))
        else
            vim.notify("DLT conversion failed: " .. cmd, vim.log.levels.ERROR)
        end
    end,
})
