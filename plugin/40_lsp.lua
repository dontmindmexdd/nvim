local add = MiniDeps.add

_G.Config.now_if_args(function()
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

	require("typescript-tools").setup({}) -- don't enable vtsls

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

_G.Config.now_if_args(function()
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

_G.Config.now_if_args(function()
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
