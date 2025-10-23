local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require("mini.deps").setup()

_G.Config = {}

local add, later, now = MiniDeps.add, MiniDeps.later, MiniDeps.now
local now_if_args = vim.fn.argc(-1) > 0 and now or later -- Use now if nvim was started with file as parameter and we need everything loaded right now
local map = vim.keymap.set

now(function()
	add("folke/which-key.nvim")

	require("which-key").setup({
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
				{ "gs", group = "surround" },
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
end)

local wk = require("which-key")

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- buffers
wk.add({
	{ "<leader>bb", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
	{ "<leader>`", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
	{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
	{ "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
	{ "<leader>bD", "<cmd>:bd<cr>", desc = "Delete Buffer and Window" },
})

local gr = vim.api.nvim_create_augroup("custom-config", {})
_G.Config.new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

now(
	function()
		require("mini.basics").setup({
			options = { basic = false },
			mappings = {
				windows = true,
			},
		})
	end
)

now(function()
	local ext3_blocklist = { scm = true, txt = true, yml = true }
	local ext4_blocklist = { json = true, yaml = true }
	require("mini.icons").setup({
		use_file_extension = function(ext, _) return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)]) end,
	})

	later(MiniIcons.mock_nvim_web_devicons)
	later(MiniIcons.tweak_lsp_kind)
end)

now(function() require("mini.notify").setup() end)

now(function() require("mini.starter").setup() end)

now(function() require("mini.statusline").setup() end)

now(function() require("mini.tabline").setup() end)

later(function() require("mini.extra").setup() end)

later(function()
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			g = MiniExtra.gen_ai_spec.buffer(),
			f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			u = ai.gen_spec.function_call(), -- u for "Usage"
			U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
			o = ai.gen_spec.treesitter({ -- code block
				a = { "@block.outer", "@conditional.outer", "@loop.outer" },
				i = { "@block.inner", "@conditional.inner", "@loop.inner" },
			}),
			c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
			t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
			d = { "%f[%d]%d+" }, -- digits
			e = { -- Word with case
				{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
				"^().*()$",
			},
		},
		search_method = "cover",
	})
end)

-- Go forward/backward with square brackets. Implements consistent sets of mappings
-- for selected targets (like buffers, diagnostic, quickfix list entries, etc.).
-- Example usage:
-- - `]b` - go to next buffer
-- - `[j` - go to previous jump inside current buffer
-- - `[Q` - go to first entry of quickfix list
-- - `]X` - go to last conflict marker in a buffer
--
-- See also:
-- - `:h MiniBracketed` - overall mapping design and list of targets
later(function() require("mini.bracketed").setup() end)

-- The built-in `:h commenting` is based on 'mini.comment'. Yet this module is
-- still enabled as it provides more customization opportunities.
later(function() require("mini.comment").setup() end)

later(function() require("mini.cursorword").setup() end)

-- Work with diff hunks that represent the difference between the buffer text and
-- some reference text set by a source. Default source uses text from Git index.
-- Also provides summary info used in developer section of 'mini.statusline'.
-- Example usage:
-- - `ghip` - apply hunks (`gh`) within *i*nside *p*aragraph
-- - `gHG` - reset hunks (`gH`) from cursor until end of buffer (`G`)
-- - `ghgh` - apply (`gh`) hunk at cursor (`gh`)
-- - `gHgh` - reset (`gH`) hunk at cursor (`gh`)
-- - `<Leader>go` - toggle overlay
--
-- See also:
-- - `:h MiniDiff-overview` - overview of how module works
-- - `:h MiniDiff-diff-summary` - available summary information
-- - `:h MiniDiff.gen_source` - available built-in sources
later(function() require("mini.diff").setup() end)

later(function() require("mini.jump").setup() end)

later(function() require("mini.jump2d").setup() end)

later(function()
	require("mini.misc").setup()
	MiniMisc.setup_auto_root()
	MiniMisc.setup_restore_cursor()
	MiniMisc.setup_termbg_sync()
end)

later(function() require("mini.move").setup() end)

later(function()
	-- Create pairs not only in Insert, but also in Command line mode
	require("mini.pairs").setup({ modes = { command = true } })
end)

-- Split and join arguments (regions inside brackets between allowed separators).
-- It uses Lua patterns to find arguments, which means it works in comments and
-- strings but can be not as accurate as tree-sitter based solutions.
-- Each action can be configured with hooks (like add/remove trailing comma).
-- Example usage:
-- - `gS` - toggle between joined (all in one line) and split (each on a separate
--   line and indented) arguments. It is dot-repeatable (see `:h .`).
--
-- See also:
-- - `:h MiniSplitjoin.gen_hook` - list of available hooks
later(function() require("mini.splitjoin").setup() end)

later(function() require("mini.surround").setup() end)

now_if_args(function()
	add("folke/snacks.nvim")

	require("snacks").setup({
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		picker = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	})

	map(
		"n",
		"<leader><space>",
		function() Snacks.picker.smart() end,
		{ desc = "Smart Find Files", noremap = true, silent = true }
	)
	map("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers", noremap = true, silent = true })
	map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep", noremap = true, silent = true })
	map(
		"n",
		"<leader>:",
		function() Snacks.picker.command_history() end,
		{ desc = "Command History", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>n",
		function() Snacks.picker.notifications() end,
		{ desc = "Notification History", noremap = true, silent = true }
	)
	map("n", "<leader>e", function() Snacks.explorer() end, { desc = "File Explorer", noremap = true, silent = true })
	-- find
	map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers", noremap = true, silent = true })
	map(
		"n",
		"<leader>fc",
		function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
		{ desc = "Find Config File", noremap = true, silent = true }
	)
	map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files", noremap = true, silent = true })
	map(
		"n",
		"<leader>fg",
		function() Snacks.picker.git_files() end,
		{ desc = "Find Git Files", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>fp",
		function() Snacks.picker.projects() end,
		{ desc = "Projects", noremap = true, silent = true }
	)
	map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent", noremap = true, silent = true })
	-- git
	map(
		"n",
		"<leader>gb",
		function() Snacks.picker.git_branches() end,
		{ desc = "Git Branches", noremap = true, silent = true }
	)
	map("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log", noremap = true, silent = true })
	map(
		"n",
		"<leader>gL",
		function() Snacks.picker.git_log_line() end,
		{ desc = "Git Log Line", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>gs",
		function() Snacks.picker.git_status() end,
		{ desc = "Git Status", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>gS",
		function() Snacks.picker.git_stash() end,
		{ desc = "Git Stash", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>gd",
		function() Snacks.picker.git_diff() end,
		{ desc = "Git Diff (Hunks)", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>gf",
		function() Snacks.picker.git_log_file() end,
		{ desc = "Git Log File", noremap = true, silent = true }
	)
	-- Grep
	map(
		"n",
		"<leader>sb",
		function() Snacks.picker.lines() end,
		{ desc = "Buffer Lines", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sB",
		function() Snacks.picker.grep_buffers() end,
		{ desc = "Grep Open Buffers", noremap = true, silent = true }
	)
	map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep", noremap = true, silent = true })
	map(
		{ "n", "x" },
		"<leader>sw",
		function() Snacks.picker.grep_word() end,
		{ desc = "Visual selection or word", noremap = true, silent = true }
	)
	-- search
	map(
		"n",
		'<leader>s"',
		function() Snacks.picker.registers() end,
		{ desc = "Registers", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>s/",
		function() Snacks.picker.search_history() end,
		{ desc = "Search History", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sa",
		function() Snacks.picker.autocmds() end,
		{ desc = "Autocmds", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sb",
		function() Snacks.picker.lines() end,
		{ desc = "Buffer Lines", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sc",
		function() Snacks.picker.command_history() end,
		{ desc = "Command History", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sC",
		function() Snacks.picker.commands() end,
		{ desc = "Commands", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sd",
		function() Snacks.picker.diagnostics() end,
		{ desc = "Diagnostics", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sD",
		function() Snacks.picker.diagnostics_buffer() end,
		{ desc = "Buffer Diagnostics", noremap = true, silent = true }
	)
	map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages", noremap = true, silent = true })
	map(
		"n",
		"<leader>sH",
		function() Snacks.picker.highlights() end,
		{ desc = "Highlights", noremap = true, silent = true }
	)
	map("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons", noremap = true, silent = true })
	map("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps", noremap = true, silent = true })
	map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps", noremap = true, silent = true })
	map(
		"n",
		"<leader>sl",
		function() Snacks.picker.loclist() end,
		{ desc = "Location List", noremap = true, silent = true }
	)
	map("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks", noremap = true, silent = true })
	map("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages", noremap = true, silent = true })
	map(
		"n",
		"<leader>sp",
		function() Snacks.picker.lazy() end,
		{ desc = "Search for Plugin Spec", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sq",
		function() Snacks.picker.qflist() end,
		{ desc = "Quickfix List", noremap = true, silent = true }
	)
	map("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume", noremap = true, silent = true })
	map(
		"n",
		"<leader>su",
		function() Snacks.picker.undo() end,
		{ desc = "Undo History", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>uC",
		function() Snacks.picker.colorschemes() end,
		{ desc = "Colorschemes", noremap = true, silent = true }
	)
	-- LSP
	map(
		"n",
		"gai",
		function() Snacks.picker.lsp_incoming_calls() end,
		{ desc = "C[a]lls Incoming", noremap = true, silent = true }
	)
	map(
		"n",
		"gao",
		function() Snacks.picker.lsp_outgoing_calls() end,
		{ desc = "C[a]lls Outgoing", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>ss",
		function() Snacks.picker.lsp_symbols() end,
		{ desc = "LSP Symbols", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>sS",
		function() Snacks.picker.lsp_workspace_symbols() end,
		{ desc = "LSP Workspace Symbols", noremap = true, silent = true }
	)
	-- Other
	map("n", "<leader>z", function() Snacks.zen() end, { desc = "Toggle Zen Mode", noremap = true, silent = true })
	map("n", "<leader>Z", function() Snacks.zen.zoom() end, { desc = "Toggle Zoom", noremap = true, silent = true })
	map(
		"n",
		"<leader>.",
		function() Snacks.scratch() end,
		{ desc = "Toggle Scratch Buffer", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>S",
		function() Snacks.scratch.select() end,
		{ desc = "Select Scratch Buffer", noremap = true, silent = true }
	)
	map(
		"n",
		"<leader>n",
		function() Snacks.notifier.show_history() end,
		{ desc = "Notification History", noremap = true, silent = true }
	)
	map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer", noremap = true, silent = true })
	map(
		"n",
		"<leader>cR",
		function() Snacks.rename.rename_file() end,
		{ desc = "Rename File", noremap = true, silent = true }
	)
	map(
		{ "n", "v" },
		"<leader>gB",
		function() Snacks.gitbrowse() end,
		{ desc = "Git Browse", noremap = true, silent = true }
	)
	map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit", noremap = true, silent = true })
	map(
		"n",
		"<leader>un",
		function() Snacks.notifier.hide() end,
		{ desc = "Dismiss All Notifications", noremap = true, silent = true }
	)
	map("n", "<c-/>", function() Snacks.terminal() end, { desc = "Toggle Terminal", noremap = true, silent = true })
	map("n", "<c-_>", function() Snacks.terminal() end, { desc = "which_key_ignore", noremap = true, silent = true })
	map(
		"n",
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
		{ desc = "Neovim News", noremap = true, silent = true }
	)

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

now_if_args(function()
	add("neovim/nvim-lspconfig")
	add("mason-org/mason.nvim")
	add("folke/lazydev.nvim")

	require("mason").setup()

	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
	})

	add({ source = "pmizio/typescript-tools.nvim", depends = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" } })

	vim.lsp.enable({
		"lua_ls",
		"jsonls",
	})

	require("typescript-tools").setup({})

	local keymaps = {
		{
			"<leader>cl",
			function() Snacks.picker.lsp_config() end,
			desc = "Toggle Inlay Hints",
		},

		-- Built-in LSP functions
		{ "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "LSP: Goto Definition", has = "definition" },
		{ "gr", function() Snacks.picker.lsp_references() end, desc = "LSP: References", nowait = true },
		{ "gI", function() Snacks.picker.lsp_implementations() end, desc = "LSP: Goto Implementation" },
		{ "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP: Goto Type Definition" },
		{ "gD", function() Snacks.picker.lsp_declarations() end, desc = "LSP: Goto Declaration" },
		{ "K", vim.lsp.buf.hover, desc = "Hover" },
		{ "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
		{ "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "LSP: Code Action", mode = { "n", "x" }, has = "codeAction" },
		{ "<leader>cr", vim.lsp.buf.rename, desc = "LSP: Rename", has = "rename" },

		-- Codelens
		{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
		{
			"<leader>cC",
			vim.lsp.codelens.refresh,
			desc = "Refresh & Display Codelens",
			mode = { "n" },
			has = "codeLens",
		},

		-- Custom functions with capability checks
		{
			"<leader>cR",
			function() Snacks.rename.rename_file() end,
			desc = "Rename File",
			mode = { "n" },
			has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
		},

		-- Example 'Snacks' keymaps with conditions
		{
			"]]",
			function() Snacks.words.jump(vim.v.count1) end,
			has = "documentHighlight",
			desc = "Next Reference",
			cond = Snacks.words.is_enabled(),
		},
		{
			"[[",
			function() Snacks.words.jump(-vim.v.count1) end,
			has = "documentHighlight",
			desc = "Prev Reference",
			cond = Snacks.words.is_enabled(),
		},
	}

	_G.Config.new_autocmd(
		"LspAttach",
		nil,
		function(_, buffer) require("utils.lsp_keymaps").on_attach(keymaps, buffer) end
	)
end)

now_if_args(function()
	add("stevearc/conform.nvim")

	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "prettierd" },
			json = { "prettierd" },
		},
		format_on_save = {
			-- These options will be passed to conform.format()
			timeout_ms = 500,
			lsp_format = "never",
		},
	})
end)

now_if_args(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		checkout = "main",
		hooks = {
			post_checkout = function() vim.cmd("TSUpdate") end,
		},
	})

	add({
		source = "nvim-treesitter/nvim-treesitter-textobjects",
		-- Same logic as for 'nvim-treesitter'
		checkout = "main",
	})

	local ensure_languages = {
		"lua",
		"vimdoc",
		"markdown",
		"typescript",
		"typescriptreact",
		"javascriptreact",
	}
	local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 end
	local to_install = vim.tbl_filter(isnt_installed, ensure_languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Ensure tree-sitter enabled after opening a file for target language
	local filetypes = {}
	for _, lang in ipairs(ensure_languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev) vim.treesitter.start(ev.buf) end

	_G.Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

add("lewis6991/gitsigns.nvim")
require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	signs_staged = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	on_attach = function(buffer)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true }) end

		map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, "Next Hunk")
		map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, "Prev Hunk")
		map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
		map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
		map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
		map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
		map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
		map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
		map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
		map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
		map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
		map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
		map("n", "<leader>ghd", gs.diffthis, "Diff This")
		map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
	end,
})

now(function()
	add("saghen/blink.cmp")

	require("blink.cmp").setup({
		fuzzy = { implementation = "lua" },
		completion = {
			signature = { enabled = true },
			documentation = { auto_show = true },
			menu = {
				draw = {
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
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100, -- show at a higher priority than lsp
				},
			},
		},
	})
end)

now(function()
	add("p00f/alabaster.nvim")
	vim.g.alabaster_floatborder = true

	vim.cmd("colorscheme alabaster")
end)

now_if_args(function()
	add("mfussenegger/nvim-lint")

	require("lint").linters_by_ft = {
		markdown = { "vale" },
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
	}

	_G.Config.new_autocmd({ "BufWritePost" }, nil, function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		require("lint").try_lint()
	end, "Run linter")
end)
