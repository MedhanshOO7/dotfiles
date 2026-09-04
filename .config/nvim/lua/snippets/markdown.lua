local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("markdown", {

	s("```", {
		t("```"),
		i(1, "cpp"), -- first jump (language)
		t(" fold title:'"),
		i(2, "title"), -- second jump
		t({ "'", "", "```" }),
	}),

    -- Report Frontmatter
    s("frontmatter", {
        t({ "---", "subject: " }),
        i(1, "dbms"),
        t({ "", "dop: " }),
        i(2, "today"),
        t({ "", "dos: " }),
        i(3, "today"),
        t({ "", "practical: " }),
        i(4, "1"),
        t({ "", "pdf: true", "---", "", "" }),
        i(0),
    }),
    s("fm", {
        t({ "---", "subject: " }),
        i(1, "dbms"),
        t({ "", "dop: today", "practical: " }),
        i(2, "1"),
        t({ "", "pdf: true", "---", "", "" }),
        i(0),
    }),

    -- Math Formulas
    s("math", {
        t({ "$$", "" }),
        i(1, "\\sum_{i=1}^{n} x_i"),
        t({ "", "$$" }),
    }),
    s("eq", {
        t({ "$$", "" }),
        i(1, "E = mc^2"),
        t({ "", "$$" }),
    }),

    -- Callouts
    s("note", {
        t({ "> [!NOTE] " }),
        i(1, "Title"),
        t({ "", "> " }),
        i(2),
    }),
    s("tip", {
        t({ "> [!TIP] " }),
        i(1, "Title"),
        t({ "", "> " }),
        i(2),
    }),
    s("warn", {
        t({ "> [!WARNING] " }),
        i(1, "Warning"),
        t({ "", "> " }),
        i(2),
    }),
    s("important", {
        t({ "> [!IMPORTANT] " }),
        i(1, "Important"),
        t({ "", "> " }),
        i(2),
    }),
    s("caution", {
        t({ "> [!CAUTION] " }),
        i(1, "Caution"),
        t({ "", "> " }),
        i(2),
    }),
    s("danger", {
        t({ "> [!DANGER] " }),
        i(1, "Danger"),
        t({ "", "> " }),
        i(2),
    }),
    s("success", {
        t({ "> [!SUCCESS] " }),
        i(1, "Success"),
        t({ "", "> " }),
        i(2),
    }),
    s("question", {
        t({ "> [!QUESTION] " }),
        i(1, "Question"),
        t({ "", "> " }),
        i(2),
    }),
    s("bug", {
        t({ "> [!BUG] " }),
        i(1, "Bug"),
        t({ "", "> " }),
        i(2),
    }),
    s("example", {
        t({ "> [!EXAMPLE] " }),
        i(1, "Example"),
        t({ "", "> " }),
        i(2),
    }),
    s("todo", {
        t({ "> [!TODO] " }),
        i(1, "Todo"),
        t({ "", "> " }),
        i(2),
    }),
})
