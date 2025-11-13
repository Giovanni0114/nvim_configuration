vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.dlt",
    callback = function(args)
        local filepath = args.file
        local tmpfile = vim.fn.tempname() .. ".log"
        local cmd = string.format("dlt-viewer -c %q %q &2>1 1>/dev/null", filepath, tmpfile)

        -- Notify user (optional)
        vim.notify("Converting DLT to text...", vim.log.levels.INFO)

        -- Run conversion synchronously
        local success = os.execute(cmd)

        if success then
            -- Edit the generated temp file instead
            vim.cmd("edit " .. vim.fn.fnameescape(tmpfile))
        else
            vim.notify("DLT conversion failed: " .. cmd, vim.log.levels.ERROR)
        end
    end,
})
