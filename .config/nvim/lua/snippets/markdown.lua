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
})
