return {
    "epwalsh/obsidian.nvim",
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    --   "BufReadPre path/to/my-vault/**.md",
    --   "BufNewFile path/to/my-vault/**.md",
    -- },
    dependencies = { "nvim-lua/plenary.nvim", },
    opts = {
        workspaces = {
            {
                name = "planner",
                path = "~/planner/",
            },
            {
                name = "kampania - Władca Demona Cienia",
                path = "~/giovannis-notes/kampanie/budzicie-sie-martwi-w-lesie/",
            },
            {
                name = "kampania - Imperium Maleictum",
                path = "~/giovannis-notes/kampanie/sektor-macharia/",
            },
            {
                name = "kampania - Powrót Wiedźmiego Króla",
                path = "~/giovannis-notes/kampanie/cwd-plany/",
            },
            {
                name = "CWD",
                path = "~/giovannis-notes/cwd-knowlegde-base/",
            },
            {
                name = "Midguard",
                path = "~/giovannis-notes/midguard-reborn/",
            },
            {
                name = "Notatki Wewnętrzy Wróg",
                path = "~/giovannis-notes/michal-warhammer/",
            },
        },
        mappings = {
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true },

            },
            ["<S-ENTER>"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = { buffer = true },
            },
        }
    },
}
