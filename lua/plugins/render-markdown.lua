return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {"nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"},
    lazy = true,
    opts = {
        bullet = {
            icons = {"•", "◦", "◆", "◇"}
        },
        checkbox = {
            unchecked = {
                icon = "󰄱",
                highlight = "RenderMarkdownUnchecked",
                scope_highlight = nil
            },
            checked = {
                icon = "󰱒",
                highlight = "RenderMarkdownChecked",
                scope_highlight = "RenderMarkdownChecked"
            },
            custom = {
                todo    = {raw = "[-]", rendered = "󰥔", highlight = "RenderMarkdownTodo", scope_highlight = nil},
                warn    = {raw = "[/]", rendered = "", highlight = "RenderMarkdownWarn", scope_highlight = nil},
                error   = {raw = "[~]", rendered = "󰜺", highlight = "RenderMarkdownError", scope_highlight = "RenderMarkdownError" }
            }
        },
        code = {
            -- Width of the code block background.
            -- | block | width of the code block  |
            -- | full  | full width of the window |
            width = "block",
            left_margin = 1,
            left_pad = 1,

            -- Determines how the top / bottom of code block are rendered.
            -- | none  | do not render a border                               |
            -- | thick | use the same highlight as the code body              |
            -- | thin  | when lines are empty overlay the above & below icons |
            -- | hide  | conceal lines unless language name or icon is added  |
            border = "thin",
        }
    }
}
