local add = MiniDeps.add

_G.Config.now_if_args(function()
	add("folke/snacks.nvim")

	require("snacks").setup({
		bigfile = { enabled = true },
		explorer = { enabled = true },
		indent = { enabled = true },
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
			"<leader>fb",
			function() Snacks.picker.buffers() end,
			desc = "Buffers",
			noremap = true,
			silent = true,
		},
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
			"<leader>fg",
			function() Snacks.picker.git_files() end,
			desc = "Find Git Files",
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
		-- git
		{
			"<leader>gb",
			function() Snacks.picker.git_branches() end,
			desc = "Git Branches",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gl",
			function() Snacks.picker.git_log() end,
			desc = "Git Log",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gL",
			function() Snacks.picker.git_log_line() end,
			desc = "Git Log Line",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gs",
			function() Snacks.picker.git_status() end,
			desc = "Git Status",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gS",
			function() Snacks.picker.git_stash() end,
			desc = "Git Stash",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gd",
			function() Snacks.picker.git_diff() end,
			desc = "Git Diff (Hunks)",
			noremap = true,
			silent = true,
		},
		{
			"<leader>gf",
			function() Snacks.picker.git_log_file() end,
			desc = "Git Log File",
			noremap = true,
			silent = true,
		},
		-- Grep
		{
			"<leader>sb",
			function() Snacks.picker.lines() end,
			desc = "Buffer Lines",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sB",
			function() Snacks.picker.grep_buffers() end,
			desc = "Grep Open Buffers",
			noremap = true,
			silent = true,
		},
		{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep", noremap = true, silent = true },
		{
			"<leader>sw",
			function() Snacks.picker.grep_word() end,
			desc = "Visual selection or word",
			noremap = true,
			silent = true,
			mode = { "n", "x" },
		},
		-- search
		{
			'<leader>s"',
			function() Snacks.picker.registers() end,
			desc = "Registers",
			noremap = true,
			silent = true,
		},
		{
			"<leader>s/",
			function() Snacks.picker.search_history() end,
			desc = "Search History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sa",
			function() Snacks.picker.autocmds() end,
			desc = "Autocmds",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sb",
			function() Snacks.picker.lines() end,
			desc = "Buffer Lines",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sc",
			function() Snacks.picker.command_history() end,
			desc = "Command History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sC",
			function() Snacks.picker.commands() end,
			desc = "Commands",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sd",
			function() Snacks.picker.diagnostics() end,
			desc = "Diagnostics",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sD",
			function() Snacks.picker.diagnostics_buffer() end,
			desc = "Buffer Diagnostics",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sh",
			function() Snacks.picker.help() end,
			desc = "Help Pages",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sH",
			function() Snacks.picker.highlights() end,
			desc = "Highlights",
			noremap = true,
			silent = true,
		},
		{ "<leader>si", function() Snacks.picker.icons() end, desc = "Icons", noremap = true, silent = true },
		{ "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps", noremap = true, silent = true },
		{
			"<leader>sk",
			function() Snacks.picker.keymaps() end,
			desc = "Keymaps",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sl",
			function() Snacks.picker.loclist() end,
			desc = "Location List",
			noremap = true,
			silent = true,
		},
		{ "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks", noremap = true, silent = true },
		{
			"<leader>sM",
			function() Snacks.picker.man() end,
			desc = "Man Pages",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sp",
			function() Snacks.picker.lazy() end,
			desc = "Search for Plugin Spec",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sq",
			function() Snacks.picker.qflist() end,
			desc = "Quickfix List",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sR",
			function() Snacks.picker.resume() end,
			desc = "Resume",
			noremap = true,
			silent = true,
		},
		{
			"<leader>su",
			function() Snacks.picker.undo() end,
			desc = "Undo History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>uC",
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
			"<leader>ss",
			function() Snacks.picker.lsp_symbols() end,
			desc = "LSP Symbols",
			noremap = true,
			silent = true,
		},
		{
			"<leader>sS",
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
			silent = true,
		},
		{
			"<leader>n",
			function() Snacks.notifier.show_history() end,
			desc = "Notification History",
			noremap = true,
			silent = true,
		},
		{
			"<leader>bd",
			function() Snacks.bufdelete() end,
			desc = "Delete Buffer",
			noremap = true,
			silent = true,
		},
		{
			"<leader>cR",
			function() Snacks.rename.rename_file() end,
			desc = "Rename File",
			noremap = true,
			silent = true,
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
		{
			"<leader>N",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end,
			desc = "Neovim News",
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
