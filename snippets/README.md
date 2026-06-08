# snippets/

[LuaSnip](https://github.com/L3MON4D3/LuaSnip) snippets, lazy-loaded from
this directory by `plugin/20-cmp.lua`.

## How it works

Filename is the filetype. `gitcommit.lua` loads in `gitcommit` buffers,
`lua.lua` in lua buffers, `all.lua` everywhere.

Each file returns a list of snippets:

```lua
local ls = require("luasnip")

return {
    ls.snippet("trigger", {
        ls.text_node("boilerplate "),
        ls.insert_node(1, "placeholder"),
    }),
}
```

Type the trigger, hit completion, tab through placeholders.

## Nodes

- `t("...")` — literal text.
- `i(idx, "default")` — tab stop. `i(0)` is the final cursor position.
- `f(fn, {node_refs})` — compute text from other nodes.
- `c(idx, {a, b, ...})` — cycle through alternatives.
- `d(idx, fn)` — return a whole sub-snippet at expansion time.

Common shorthand:

```lua
local ls = require("luasnip")
local s, t, i, f, c, d = ls.snippet, ls.text_node, ls.insert_node,
    ls.function_node, ls.choice_node, ls.dynamic_node
```

## Function nodes

Pull data in at expansion time. Example — stamp the Jira ticket from the
current branch name:

```lua
s("jirabranch", {
    t("Jira: closes "),
    f(function()
        local branch = vim.fn.system("git symbolic-ref --short HEAD"):gsub("\n", "")
        return branch:match("[A-Z]+%-%d+") or "TICKET"
    end),
})
```

## `fmt` for readability

Once you have more than a couple nodes, the list form gets ugly. Use `fmt`:

```lua
local fmt = require("luasnip.extras.fmt").fmt

s("func", fmt([[
    function {}({})
        {}
    end
]], { i(1, "name"), i(2), i(0) }))
```

## Other features

- Regex triggers: `{ trigEngine = "pattern" }`
- Conditional expansion: `{ condition = function() ... end }`
- Auto-expanding (no completion needed): `{ snippetType = "autosnippet" }`

See `:help luasnip` for the full list.

## Telescope

`telescope-luasnip` is loaded; bind it in `plugin/telescope.lua` to browse
loaded snippets (the keymap is currently commented out).

## Adding a file

1. Create `<filetype>.lua`.
2. Return a table of `ls.snippet(...)` calls.
3. Open a fresh buffer of that filetype — it's lazy-loaded, no restart
   needed.
