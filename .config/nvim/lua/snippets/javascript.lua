local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("clog", {
        t("console.log("),
        i(1),
        t(");"),
    }),
}
