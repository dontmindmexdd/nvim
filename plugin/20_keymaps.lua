local now, add = MiniDeps.now, MiniDeps.add

now(function()
	add("folke/which-key.nvim")

	local wk = require("which-key")
	wk.setup({
		preset = "helix",
		defaults = {},
		spec = {
			{
				mode = { "n", "v" },
				{ "<leader><tab>", group = "tabs" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>dp", group = "profiler" },
				{ "<leader>f", group = "file/find" },
				{ "<leader>g", group = "git" },
				{ "<leader>gh", group = "hunks" },
				{ "<leader>q", group = "quit/session" },
				{ "<leader>s", group = "search" },
				{ "<leader>u", group = "ui" },
				{ "<leader>x", group = "diagnostics/quickfix" },
				{ "[", group = "prev" },
				{ "]", group = "next" },
				{ "g", group = "goto" },
				{ "m", group = "mark" },
				{ "s", group = "surround" },
				{ "z", group = "fold" },
				{
					"<leader>b",
					group = "buffer",
					expand = function() return require("which-key.extras").expand.buf() end,
				},
				{
					"<leader>w",
					group = "windows",
					proxy = "<c-w>",
					expand = function() return require("which-key.extras").expand.win() end,
				},
				-- better descriptions
				{ "gx", desc = "Open with system app" },
			},
		},
	})

	wk.add({
		{ mode = { "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", desc = "Down", expr = true, silent = true },
		{ mode = { "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", desc = "Up", expr = true, silent = true },
		{ "<leader>bb", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
		{ "<leader>`", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
		{ "<leader>bD", "<cmd>:bd<cr>", desc = "Delete Buffer and Window" },
	})
end)
