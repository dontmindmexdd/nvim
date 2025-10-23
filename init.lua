-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
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

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

local add, later, now = MiniDeps.add, MiniDeps.later, MiniDeps.now
local now_if_args = vim.fn.argc(-1) > 0 and now or later -- Use now if nvim was started with file as parameter and we need everything loaded right now
local map = vim.keymap.set

local new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

-- ┌──────────────────────────┐
-- │ Built-in Neovim behavior │
-- └──────────────────────────┘
-- See `:h 'xxx'` (replace `xxx` with actual option name).
--
-- Option values can be customized on per buffer or window basis.

-- stylua: ignore start
-- General ====================================================================
vim.g.mapleader = ' ' -- Use `<Space>` as <Leader> key

vim.o.mouse       = 'a'            -- Enable mouse
vim.o.mousescroll = 'ver:25,hor:6' -- Customize mouse scroll
vim.o.switchbuf   = 'usetab'       -- Use already opened buffers when switching
vim.o.undofile    = true           -- Enable persistent undo
vim.o.clipboard = "unnamedplus"   -- Use system clipboard (required wl-copy/pb-copy)

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h" -- Limit ShaDa file (for startup)

-- Enable all filetype plugins and syntax (if not enabled, for better startup)
vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end

-- UI =========================================================================
vim.o.breakindent    = true       -- Indent wrapped lines to match line start
vim.o.breakindentopt = 'list:-1'  -- Add padding for lists (if 'wrap' is set)
vim.o.colorcolumn    = '+1'       -- Draw column on the right of maximum width
vim.o.cursorline     = true       -- Enable current line highlighting
vim.o.linebreak      = true       -- Wrap lines at 'breakat' (if 'wrap' is set)
vim.o.number         = true       -- Show line numbers
vim.o.relativenumber = true       -- Show relative line numbers
vim.o.pumheight      = 10         -- Make popup menu smaller
vim.o.ruler          = false      -- Don't show cursor coordinates
vim.o.shortmess      = 'CFOSWaco' -- Disable some built-in completion messages
vim.o.showmode       = false      -- Don't show mode in command line
vim.o.signcolumn     = 'yes'      -- Always show signcolumn (less flicker)
vim.o.splitbelow     = true       -- Horizontal splits will be below
vim.o.splitkeep      = 'screen'   -- Reduce scroll during window split
vim.o.splitright     = true       -- Vertical splits will be to the right
vim.o.winborder      = 'single'   -- Use border in floating windows
vim.o.wrap           = false      -- Don't visually wrap lines (toggle with \w)
vim.o.scrolloff      = 10         -- Keep 10 lines on screen

vim.o.cursorlineopt  = 'screenline,number' -- Show cursor line per screen line

-- Special UI symbols. More is set via 'mini.basics' later.
vim.o.fillchars = 'eob: ,fold:╌'
vim.o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '

-- Folds (see `:h fold-commands`, `:h zM`, `:h zR`, `:h zA`, `:h zj`)
vim.o.foldlevel   = 10       -- Fold nothing by default; set to 0 or 1 to fold
vim.o.foldmethod  = 'indent' -- Fold based on indent level
vim.o.foldnestmax = 10       -- Limit number of fold levels
vim.o.foldtext    = ''       -- Show text under fold with its highlighting

-- Editing ====================================================================
vim.o.autoindent    = true    -- Use auto indent
vim.o.expandtab     = true    -- Convert tabs to spaces
vim.o.formatoptions = 'rqnl1j'-- Improve comment editing
vim.o.ignorecase    = true    -- Ignore case during search
vim.o.incsearch     = true    -- Show search matches while typing
vim.o.infercase     = true    -- Infer case in built-in completion
vim.o.shiftwidth    = 2       -- Use this number of spaces for indentation
vim.o.smartcase     = true    -- Respect case if search pattern has upper case
vim.o.smartindent   = true    -- Make indenting smart
vim.o.spelloptions  = 'camel' -- Treat camelCase word parts as separate words
vim.o.tabstop       = 2       -- Show tab as this number of spaces
vim.o.virtualedit   = 'block' -- Allow going past end of line in blockwise mode

vim.o.iskeyword = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part

-- Pattern for a start of numbered list (used in `gw`). This reads as
-- "Start of list item is: at least one special character (digit, -, +, *)
-- possibly followed by punctuation (. or `)`) followed by at least one space".
vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- Built-in completion
vim.o.complete    = '.,w,b,kspell'                  -- Use less sources
vim.o.completeopt = 'menuone,noselect,fuzzy,nosort' -- Use custom behavior

-- Lower LSP semantic token hightlight priorities to use treesitter highlighting
vim.highlight.priorities.semantic_tokens = 95

-- Autocommands ===============================================================

-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
local f = function() vim.cmd('setlocal formatoptions-=c formatoptions-=o') end
new_autocmd('FileType', nil, f, "Proper 'formatoptions'")

-- There are other autocommands created by 'mini.basics'. See 'plugin/30_mini.lua'.

-- Diagnostics ================================================================

-- Neovim has built-in support for showing diagnostic messages. This configures
-- a more conservative display while still being useful.
-- See `:h vim.diagnostic` and `:h vim.diagnostic.config()`.
local diagnostic_opts = {
  -- Show signs on top of any other sign, but only for warnings and errors
  signs = { priority = 9999, severity = { min = 'HINT', max = 'ERROR' } },

  -- Show all diagnostics as underline (for their messages type `<Leader>ld`)
  underline = { severity = { min = 'HINT', max = 'ERROR' } },

  -- Show more details immediately for errors on the current line
  virtual_text = true,

  -- Don't update diagnostics when typing
  update_in_insert = false,
}

-- Use `later()` to avoid sourcing `vim.diagnostic` on startup
later(function() vim.diagnostic.config(diagnostic_opts) end)
-- stylua: ignore end

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
		-- 'mini.ai' can be extended with custom textobjects
		custom_textobjects = {
			g = MiniExtra.gen_ai_spec.buffer(),
			f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		},
		-- 'mini.ai' by default mostly mimics built-in search behavior: first try
		-- to find textobject covering cursor, then try to find to the right.
		-- Although this works in most cases, some are confusing. It is more robust to
		-- always try to search only covering textobject and explicitly ask to search
		-- for next (`an`/`in`) or last (`an`/`il`).
		-- Try this. If you don't like it - delete next line and this comment.
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

-- Remove buffers. Opened files occupy space in tabline and buffer picker.
-- When not needed, they can be removed. Example usage:
-- - `<Leader>bw` - completely wipeout current buffer (see `:h :bwipeout`)
-- - `<Leader>bW` - completely wipeout current buffer even if it has changes
-- - `<Leader>bd` - delete current buffer (see `:h :bdelete`)
later(function() require("mini.bufremove").setup() end)

-- The built-in `:h commenting` is based on 'mini.comment'. Yet this module is
-- still enabled as it provides more customization opportunities.
later(function() require("mini.comment").setup() end)

-- Completion and signature help. Implements async "two stage" autocompletion:
-- - Based on attached LSP servers that support completion.
-- - Fallback (based on built-in keyword completion) if there is no LSP candidates.
--
-- Example usage in Insert mode with attached LSP:
-- - Start typing text that should be recognized by LSP (like variable name).
-- - After 100ms a popup menu with candidates appears.
-- - Press `<Tab>` / `<S-Tab>` to navigate down/up the list. These are set up
--   in 'mini.keymap'. You can also use `<C-n>` / `<C-p>`.
-- - During navigation there is an info window to the right showing extra info
--   that the LSP server can provide about the candidate. It appears after the
--   candidate stays selected for 100ms. Use `<C-f>` / `<C-b>` to scroll it.
-- - Navigating to an entry also changes buffer text. If you are happy with it,
--   keep typing after it. To discard completion completely, press `<C-e>`.
-- - After pressing special trigger(s), usually `(`, a window appears that shows
--   the signature of the current function/method. It gets updated as you type
--   showing the currently active parameter.
--
-- Example usage in Insert mode without an attached LSP or in places not
-- supported by the LSP (like comments):
-- - Start typing a word that is present in current or opened buffers.
-- - After 100ms popup menu with candidates appears.
-- - Navigate with `<Tab>` / `<S-Tab>` or `<C-n>` / `<C-p>`. This also updates
--   buffer text. If happy with choice, keep typing. Stop with `<C-e>`.
--
-- It also works with snippet candidates provided by LSP server. Best experience
-- when paired with 'mini.snippets' (which is set up in this file).
-- later(function()
-- 	-- Customize post-processing of LSP responses for a better user experience.
-- 	-- Don't show 'Text' suggestions (usually noisy) and show snippets last.
-- 	local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
-- 	local process_items = function(items, base)
-- 		return MiniCompletion.default_process_items(items, base, process_items_opts)
-- 	end
-- 	require("mini.completion").setup({
-- 		delay = { completion = 50, info = 50, signature = 50 },
-- 		lsp_completion = {
-- 			-- Without this config autocompletion is set up through `:h 'completefunc'`.
-- 			-- Although not needed, setting up through `:h 'omnifunc'` is cleaner
-- 			-- (sets up only when needed) and makes it possible to use `<C-u>`.
-- 			source_func = "omnifunc",
-- 			auto_setup = false,
-- 			process_items = process_items,
-- 		},
-- 		window = {
-- 			info = { border = "single" },
-- 			signature = { border = "single" },
-- 		},
-- 	})
--
-- 	-- Set 'omnifunc' for LSP completion only when needed.
-- 	local on_attach = function(ev)
-- 		vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
-- 	end
--
-- 	new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")
--
-- 	-- Advertise to servers that Neovim now supports certain set of completion and
-- 	-- signature features through 'mini.completion'.
-- 	vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
-- end)

-- Manage and expand snippets (templates for a frequently used text).
-- Typical workflow is to type snippet's (configurable) prefix and expand it
-- into a snippet session.
--
-- How to manage snippets:
-- - 'mini.snippets' itself doesn't come with preconfigured snippets. Instead there
--   is a flexible system of how snippets are prepared before expanding.
--   They can come from pre-defined path on disk, 'snippets/' directories inside
--   config or plugins, defined inside `setup()` call directly.
-- - This config, however, does come with snippet configuration:
--     - 'snippets/global.json' is a file with global snippets that will be
--       available in any buffer
--     - 'after/snippets/lua.json' defines personal snippets for Lua language
--     - 'friendly-snippets' plugin configured in 'plugin/40_plugins.lua' provides
--       a collection of language snippets
--
-- How to expand a snippet in Insert mode:
-- - If you know snippet's prefix, type it as a word and press `<C-j>`. Snippet's
--   body should be inserted instead of the prefix.
-- - If you don't remember snippet's prefix, type only part of it (or none at all)
--   and press `<C-j>`. It should show picker with all snippets that have prefixes
--   matching typed characters (or all snippets if none was typed).
--   Choose one and its body should be inserted instead of previously typed text.
--
-- How to navigate during snippet session:
-- - Snippets can contain tabstops - places for user to interactively adjust text.
--   Each tabstop is highlighted depending on session progression - whether tabstop
--   is current, was or was not visited. If tabstop doesn't yet have text, it is
--   visualized with special "ghost" inline text: • and ∎ by default.
-- - Type necessary text at current tabstop and navigate to next/previous one
--   by pressing `<C-l>` / `<C-h>`.
-- - Repeat previous step until you reach special final tabstop, usually denoted
--   by ∎ symbol. If you spotted a mistake in an earlier tabstop, navigate to it
--   and return back to the final tabstop.
-- - To end a snippet session when at final tabstop, keep typing or go into
--   Normal mode. To force end snippet session, press `<C-c>`.
--
-- See also:
-- - `:h MiniSnippets-overview` - overview of how module works
-- - `:h MiniSnippets-examples` - examples of common setups
-- - `:h MiniSnippets-session` - details about snippet session
-- - `:h MiniSnippets.gen_loader` - list of available loaders
-- later(function()
-- 	-- Define language patterns to work better with 'friendly-snippets'
-- 	local latex_patterns = { "latex/**/*.json", "**/latex.json" }
-- 	local lang_patterns = {
-- 		tex = latex_patterns,
-- 		plaintex = latex_patterns,
-- 		-- Recognize special injected language of markdown tree-sitter parser
-- 		markdown_inline = { "markdown.json" },
-- 		typescript = { "javascript/**/javascript.json", "javascript/**/typescript.json", "javascript/**/tsdoc.json" },
-- 	}
--
-- 	add("rafamadriz/friendly-snippets")
-- 	local snippets = require("mini.snippets")
-- 	snippets.setup({
-- 		snippets = {
-- 			-- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
-- 			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
-- 		},
-- 	})
--
-- 	-- By default snippets available at cursor are not shown as candidates in
-- 	-- 'mini.completion' menu. This requires a dedicated in-process LSP server
-- 	-- that will provide them. To have that, uncomment next line (use `gcc`).
-- 	MiniSnippets.start_lsp_server()
-- end)

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

later(function() require("mini.indentscope").setup() end)

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
	add("neovim/nvim-lspconfig")
	add("mason-org/mason.nvim")

	require("mason").setup()

	add({ source = "pmizio/typescript-tools.nvim", depends = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" } })

	vim.lsp.enable({
		"lua_ls",
		"jsonls",
	})

	require("typescript-tools").setup({})
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

	new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

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

later(function()
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
		"gd",
		function() Snacks.picker.lsp_definitions() end,
		{ desc = "Goto Definition", noremap = true, silent = true }
	)
	map(
		"n",
		"gD",
		function() Snacks.picker.lsp_declarations() end,
		{ desc = "Goto Declaration", noremap = true, silent = true }
	)
	map(
		"n",
		"gr",
		function() Snacks.picker.lsp_references() end,
		{ desc = "References", nowait = true, noremap = true, silent = true }
	)
	map(
		"n",
		"gI",
		function() Snacks.picker.lsp_implementations() end,
		{ desc = "Goto Implementation", noremap = true, silent = true }
	)
	map(
		"n",
		"gy",
		function() Snacks.picker.lsp_type_definitions() end,
		{ desc = "Goto T[y]pe Definition", noremap = true, silent = true }
	)
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
		{ "n", "t" },
		"]]",
		function() Snacks.words.jump(vim.v.count1) end,
		{ desc = "Next Reference", noremap = true, silent = true }
	)
	map(
		{ "n", "t" },
		"[[",
		function() Snacks.words.jump(-vim.v.count1) end,
		{ desc = "Prev Reference", noremap = true, silent = true }
	)
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

-- stylua: ignore start
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

	new_autocmd({ "BufWritePost" }, nil, function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		require("lint").try_lint()
	end, "Run linter")
end)
