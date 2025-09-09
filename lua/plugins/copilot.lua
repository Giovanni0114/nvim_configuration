vim.keymap.set("n", "<leader>ac", function()
    require("copilot").setup({
        suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 200,
            trigger_on_accept = true,
            keymap = {
                accept = "<A-l>",
                accept_word = false,
                accept_line = false,
                dismiss = "<A-[>",
            },
        },
        copilot_model = "gpt-4o-copilot"
    })
end
, { expr = true, silent = true })


return {
    "zbirenbaum/copilot.lua",
    lazy = "VeryLazy",
    cmd = "Copilot",
}
