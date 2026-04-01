vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

opts = {
    bullet = {
        icons = { "•", "◦", "◆", "◇" }
    },
    checkbox = {
        unchecked = {
            icon = "󰄱 ",
            highlight = "RenderMarkdownUnchecked",
            scope_highlight = nil
        },
        checked = {
            icon = "󰱒 ",
            highlight = "RenderMarkdownChecked",
            scope_highlight = "RenderMarkdownChecked"
        },
        custom = {
            todo  = { raw = "[=]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
            warn  = { raw = "[/]", rendered = " ", highlight = "RenderMarkdownWarn", scope_highlight = "RenderMarkdownWarn" },
            error = { raw = "[~]", rendered = "󰜺 ", highlight = "RenderMarkdownError", scope_highlight = "RenderMarkdownError" },
            abort = { raw = "[_]", rendered = "󰚃 ", highlight = "RenderMarkdownHtmlComment", scope_highlight = "@markup.strikethrough" }
        }
    },
    code = {
        width = "block",
        right_pad = 1,
        border = "thin",
    }
}  

require("render-markdown").setup(opts)
