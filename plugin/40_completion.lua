local later, add = MiniDeps.later, MiniDeps.add

later(function()
	add("saghen/blink.cmp")
	add("rafamadriz/friendly-snippets")

	require("blink.cmp").setup({
		appearance = {
			nerd_font_variant = "normal",
		},
		fuzzy = { implementation = "lua" },
		completion = {
			documentation = { auto_show = true },
			menu = {
				draw = {
					columns = { { "kind_icon", "label", "label_description", gap = 2 }, { "kind" } },
					components = {
						kind_icon = {
							text = function(ctx)
								local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return kind_icon
							end,
							-- (optional) use highlights from mini.icons
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
						kind = {
							-- (optional) use highlights from mini.icons
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl
							end,
						},
					},
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				lua = { inherit_defaults = true, "lazydev" },
			},
			providers = {
				text = {
					module = "blink.cmp.sources.text",
					score_offset = -99,
					max_items = 3,
				},
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
			},
		},
	})
end)
