return  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
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
        })
      end,
}
