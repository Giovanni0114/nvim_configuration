return {
    "folke/sidekick.nvim",
    opts = {
        cli = {
            win = {
                keys = {
                    prompt = { "<C-q>", "prompt", mode = "t", desc = "insert prompt or context" },
                }
            },
            tools = {
                copilot_cave = {
                    cmd = { "copilot", "--model=auto", "-i" ,"\"Use skill tool to invoke caveman skill, level full.\"" }
                }
            },
            mux = {
                backend = "tmux",
                enabled = true,
            },
        },
        nes = {
            enabled = false,
        }
    },
    keys = {
        {
            "<C-/>",
            function() require("sidekick.cli").toggle() end,
            mode = { "x", "n", "i", "t" },
            desc = "Sidekick Toggle CLI",
        },
        {
            "<leader>as",
            function() require("sidekick.cli").select() end,
            -- Or to select only installed tools:
            -- require("sidekick.cli").select({ filter = { installed = true } })
            desc = "Select CLI",
        },
        {
            "<leader>ad",
            function() require("sidekick.cli").close() end,
            desc = "Detach a CLI Session",
        },
        {
            "<leader>at",
            function() require("sidekick.cli").send({ msg = "{this}" }) end,
            mode = { "x", "n" },
            desc = "Send This",
        },
        {
            "<leader>af",
            function() require("sidekick.cli").send({ msg = "{file}" }) end,
            desc = "Send File",
        },
        {
            "<leader>av",
            function() require("sidekick.cli").send({ msg = "{selection}" }) end,
            mode = { "x" },
            desc = "Send Visual Selection",
        },
        {
            "<leader>aA",
            function() require("sidekick.cli").prompt() end,
            mode = { "n", "x" },
            desc = "Sidekick Select Prompt",
        },
    },
}
