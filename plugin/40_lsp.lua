local add, now = MiniDeps.add, MiniDeps.now

-- A generic utility to set buffer-local LSP keymaps based on server capabilities

---
--- Checks if any client attached to the buffer supports the given LSP method.
---@param buffer number The buffer number
---@param method string|string[] The LSP method (e.g., "definition") or list of methods.
---@return boolean
local function has(buffer, method)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if has(buffer, m) then
				return true
			end
		end
		return false
	end
	-- Prepend "textDocument/" if it's a standard method without a prefix
	method = method:find("/") and method or "textDocument/" .. method
	local clients = vim.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		if client:supports_method(method) then
			return true
		end
	end
	return false
end

---
--- Converts a key spec table into arguments for vim.keymap.set
---@param key_spec table The key specification table
---@return string|string[]? mode
---@return string? lhs
---@return function|string? rhs
---@return table? opts
local function parse_key_spec(key_spec)
	local mode = key_spec.mode or "n"
	local lhs = key_spec[1] or key_spec.lhs
	local rhs = key_spec[2] or key_spec.rhs

	if not lhs or not rhs then
		vim.notify("Invalid keymap spec: missing lhs (key[1]) or rhs (key[2])", vim.log.levels.WARN)
		return nil, nil, nil, nil
	end

	-- Create the opts table for vim.keymap.set
	local opts = {}
	for k, v in pairs(key_spec) do
		-- Copy all keys *except* for the ones we've already handled
		-- (mode, lhs, rhs) or our custom ones (has, cond).
		if k ~= 1 and k ~= 2 and k ~= "lhs" and k ~= "rhs" and k ~= "mode" and k ~= "has" and k ~= "cond" then
			opts[k] = v
		end
	end

	-- Set defaults (same as lazy.nvim's)
	opts.silent = opts.silent ~= false -- Default to silent

	return mode, lhs, rhs, opts
end

---
--- The main on_attach function to be called by lspconfig.
--- It sets keymaps dynamically based on server capabilities.
---@param keymap_spec table[] Your list of keymap specifications.
---@param buffer number The buffer number from on_attach.
local function on_attach(keymap_spec, buffer)
	if not keymap_spec then
		return
	end

	for _, keys in ipairs(keymap_spec) do
		-- 1. Check 'has' capability
		local has_capability = not keys.has or has(buffer, keys.has)

		-- 2. Check 'cond' function
		local is_cond_met = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

		-- 3. If both pass, set the keymap
		if has_capability and is_cond_met then
			local mode, lhs, rhs, opts = parse_key_spec(keys)
			local current_filetype = vim.bo.filetype
			local icon, highlight = require("mini.icons").get("filetype", current_filetype)

			if mode and lhs and rhs and opts then
				require("which-key").add({
					{
						lhs,
						rhs,
						buffer = buffer,
						desc = opts.desc,
						mode = mode,
						icon = { icon = icon, hl = highlight },
					},
				})
			end
		end
	end
end

now(function()
	add("neovim/nvim-lspconfig")
	add("mason-org/mason.nvim")
	add("WhoIsSethDaniel/mason-tool-installer.nvim")
	add("folke/lazydev.nvim")

	require("mason").setup()
	require("mason-tool-installer").setup({
		ensure_installed = {
			"vim-language-server",
			"lua-language-server",
			"stylua",
			"prettierd",
			"eslint_d",
			"jsonlint",
			"json-lsp",
			"commitlint",
			"vtsls",
			"markdownlint-cli2",
			"marksman",
		},
	})

	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
		},
	})

	-- add({ source = "pmizio/typescript-tools.nvim", depends = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" } })

	vim.lsp.enable({
		"lua_ls",
		"jsonls",
		"vtsls",
		"vim_ls",
		"jsonls",
		"marksman",
	})

	-- require("typescript-tools").setup({}) -- don't enable vtsls

	local keymaps = {
		{
			"<leader>cl",
			function() Snacks.picker.lsp_config() end,
			desc = "Toggle Inlay Hints",
		},

		-- Built-in LSP functions
		{ "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "LSP: Goto Definition", has = "definition" },
		{ "grr", function() Snacks.picker.lsp_references() end, desc = "LSP: References", nowait = true },
		{ "gri", function() Snacks.picker.lsp_implementations() end, desc = "LSP: Goto Implementation" },
		{ "gry", function() Snacks.picker.lsp_type_definitions() end, desc = "LSP: Goto Type Definition" },
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

	_G.Config.new_autocmd("LspAttach", nil, function(_, buffer) on_attach(keymaps, buffer) end)
end)

_G.Config.now_if_args(function()
	add("stevearc/conform.nvim")

	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "prettierd" },
			javascript = { "prettierd" },
			json = { "prettierd" },
			["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
			["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
		},
		formatters = {
			["markdown-toc"] = {
				condition = function(_, ctx)
					for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
						if line:find("<!%-%- toc %-%->") then
							return true
						end
					end
				end,
			},
			["markdownlint-cli2"] = {
				condition = function(_, ctx)
					local diag = vim.tbl_filter(
						function(d) return d.source == "markdownlint" end,
						vim.diagnostic.get(ctx.buf)
					)
					return #diag > 0
				end,
			},
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
		markdown = { "markdownlint-cli2" },
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		json = { "jsonlint" },
	}

	_G.Config.new_autocmd({ "BufWritePost" }, nil, function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		require("lint").try_lint()
	end, "Run linter")
end)
