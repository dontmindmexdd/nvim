local add, now = MiniDeps.add, MiniDeps.now

now(function()
	add("folke/snacks.nvim")

	require("snacks").setup({
		bigfile = { enabled = true },
		explorer = { enabled = true },
		indent = {
			char = "",
			enabled = true,
			scope = {
				enabled = true,
				char = "",
			},
			chunk = {
				enabled = true,
				only_current = true,
			},
		},
		notifier = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	})

	require("which-key").add({
		{
			"<leader><space>",
			function() Snacks.picker.smart() end,
			desc = "Smart Find Files",
			noremap = true,
			silent = true,
		},
		{
			"<leader>,",
			function() Snacks.picker.buffers() end,
			desc = "Buffers",
			noremap = true,
			silent = true,
		},
		{ "<leader>/", function() Snacks.picker.grep() end, desc = "Grep", noremap = true, silent = true },
		{
			"<leader>:",
			function() Snacks.picker.command_history() end,
			desc = "Command History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>n",
			function() Snacks.picker.notifications() end,
			desc = "Notification History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>e",
			function() Snacks.explorer() end,
			desc = "File Explorer",
			noremap = true,
			silent = true,
		},
		-- find
		{
			"<leader>fc",
			function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
			desc = "Find Config File",
			noremap = true,
			silent = true,
		},
		{
			"<leader>ff",
			function() Snacks.picker.files() end,
			desc = "Find Files",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fp",
			function() Snacks.picker.projects() end,
			desc = "Projects",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fr",
			function() Snacks.picker.recent() end,
			desc = "Recent",
			noremap = true,
			silent = true,
		},
		-- Grep
		{
			"<leader>fb",
			function() Snacks.picker.lines() end,
			desc = "Buffer Lines",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fB",
			function() Snacks.picker.grep_buffers() end,
			desc = "Grep Open Buffers",
			noremap = true,
			silent = true,
		},
		{ "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep", noremap = true, silent = true },
		{
			"<leader>fw",
			function() Snacks.picker.grep_word() end,
			desc = "Visual selection or word",
			noremap = true,
			silent = true,
			mode = { "n", "x" },
		},
		-- search
		{
			'<leader>f"',
			function() Snacks.picker.registers() end,
			desc = "Registers",
			noremap = true,
			silent = true,
		},
		{
			"<leader>f/",
			function() Snacks.picker.search_history() end,
			desc = "Search History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fa",
			function() Snacks.picker.autocmds() end,
			desc = "Autocmds",
			noremap = true,
			silent = true,
		},
		{
			"<leader>f:",
			function() Snacks.picker.command_history() end,
			desc = "Command History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>f",
			function() Snacks.picker.commands() end,
			desc = "Commands",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fd",
			function() Snacks.picker.diagnostics() end,
			desc = "Diagnostics",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fD",
			function() Snacks.picker.diagnostics_buffer() end,
			desc = "Buffer Diagnostics",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fh",
			function() Snacks.picker.help() end,
			desc = "Help Pages",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fH",
			function() Snacks.picker.highlights() end,
			desc = "Highlights",
			noremap = true,
			silent = true,
		},
		{ "<leader>fi", function() Snacks.picker.icons() end, desc = "Icons", noremap = true, silent = true },
		{ "<leader>fj", function() Snacks.picker.jumps() end, desc = "Jumps", noremap = true, silent = true },
		{
			"<leader>fk",
			function() Snacks.picker.keymaps() end,
			desc = "Keymaps",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fl",
			function() Snacks.picker.loclist() end,
			desc = "Location List",
			noremap = true,
			silent = true,
		},
		{ "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks", noremap = true, silent = true },
		{
			"<leader>fM",
			function() Snacks.picker.man() end,
			desc = "Man Pages",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fq",
			function() Snacks.picker.qflist() end,
			desc = "Quickfix List",
			noremap = true,
			silent = true,
		},
		{
			"<leader>f<CR>",
			function() Snacks.picker.resume() end,
			desc = "Resume",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fu",
			function() Snacks.picker.undo() end,
			desc = "Undo History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fC",
			function() Snacks.picker.colorschemes() end,
			desc = "Colorschemes",
			noremap = true,
			silent = true,
		},
		-- LSP
		{
			"gai",
			function() Snacks.picker.lsp_incoming_calls() end,
			desc = "Calls Incoming",
			noremap = true,
			silent = true,
		},
		{
			"gao",
			function() Snacks.picker.lsp_outgoing_calls() end,
			desc = "Calls Outgoing",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fs",
			function() Snacks.picker.lsp_symbols() end,
			desc = "LSP Symbols",
			noremap = true,
			silent = true,
		},
		{
			"<leader>fS",
			function() Snacks.picker.lsp_workspace_symbols() end,
			desc = "LSP Workspace Symbols",
			noremap = true,
			silent = true,
		},
		-- Other
		{ "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode", noremap = true, silent = true },
		{ "<leader>Z", function() Snacks.zen.zoom() end, desc = "Toggle Zoom", noremap = true, silent = true },
		{
			"<leader>.",
			function() Snacks.scratch() end,
			desc = "Toggle Scratch Buffer",
			noremap = true,
			silent = true,
		},
		{
			"<leader>S",
			function() Snacks.scratch.select() end,
			desc = "Select Scratch Buffer",
			noremap = true,
			ilent = true,
		},
		{
			"<leader>gB",
			function() Snacks.gitbrowse() end,
			desc = "Git Browse",
			noremap = true,
			silent = true,
			mode = { "n", "v" },
		},
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit", noremap = true, silent = true },
		{
			"<leader>un",
			function() Snacks.notifier.hide() end,
			desc = "Dismiss All Notifications",
			noremap = true,
			silent = true,
		},
		{ "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal", noremap = true, silent = true },
		{
			"<c-_>",
			function() Snacks.terminal() end,
			desc = "which_key_ignore",
			noremap = true,
			silent = true,
		},
	})

	-- Create some toggle mappings
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
	Snacks.toggle.diagnostics():map("<leader>ud")
	Snacks.toggle.line_number():map("<leader>ul")
	Snacks.toggle
		.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
		:map("<leader>uc")
	Snacks.toggle.treesitter():map("<leader>uT")
	Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
	Snacks.toggle.inlay_hints():map("<leader>uh")
	Snacks.toggle.indent():map("<leader>ug")
	Snacks.toggle.dim():map("<leader>uD")
end)
