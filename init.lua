local exit_code = io.popen "grep -q 'latte' ~/.config/alacritty/alacritty.toml \necho _$?":read '*a':match '.*%D(%d+)' + 0

if exit_code == 0 then
    vim.opt.background = "light"
else
    vim.opt.background = "dark"
end

require("main")
