vim.api.nvim_create_user_command("PyToJson", function(opts)
    local range = ""
    if opts.range > 0 then
        range = string.format("%d,%d", opts.line1, opts.line2)
    else
        range = "%"
    end

    vim.cmd(range .. [[s/'/"/ge]])
    vim.cmd(range .. [[s/\<None\>/null/ge]])
    vim.cmd(range .. [[s/\<True\>/true/ge]])
    vim.cmd(range .. [[s/\<False\>/false/ge]])

    if range ~= "%" then
        vim.cmd(range .. [[!jq]])
    end
end, { range = true })
