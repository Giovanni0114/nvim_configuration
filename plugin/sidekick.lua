vim.pack.add({ "https://github.com/folke/sidekick.nvim" })

opts = {
    cli = {
        win = {
            keys = {
                prompt = { "<c-q>", "prompt", mode = "t", desc = "insert prompt or context" },
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
}
require("sidekick").setup(opts)

vim.keymap.set("n", "<C-.>", require("sidekick.cli").toggle, { desc = "Sidekick Toggle" })
vim.keymap.set("n", "<leader>aa", require("sidekick.cli").prompt, { desc = "Sidekick Select Prompt" })
vim.keymap.set("n", "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end,
    { desc = "Sidekick Send Selection" })
vim.keymap.set("n", "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end,
    { desc = "Sidekick Send this" })
vim.keymap.set("n", "<leader>af", function() require("sidekick.cli").send({ msg = "{selection}" }) end,
    { desc = "Sidekick Send file" })
