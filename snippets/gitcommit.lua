local ls = require("luasnip")

return {
    ls.snippet("jiracloses", {
        ls.text_node("Jira: closes "),
        ls.insert_node(1, "TICKET"),
    }),
    ls.snippet("jiracontrib", {
        ls.text_node("Jira: contributes-to "),
        ls.insert_node(1, "TICKET"),
    }),
    ls.snippet("dependson", {
        ls.text_node("Depends-On: "),
        ls.insert_node(1, "LINK"),
    }),
}
