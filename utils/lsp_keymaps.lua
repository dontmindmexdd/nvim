-- File: lua/utils/lsp_keymaps.lua
--
-- A generic utility to set buffer-local LSP keymaps based on
-- server capabilities, with no plugin dependencies.

local M = {}

---
--- Checks if any client attached to the buffer supports the given LSP method.
---@param buffer number The buffer number
---@param method string|string[] The LSP method (e.g., "definition") or list of methods.
---@return boolean
function M.has(buffer, method)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if M.has(buffer, m) then
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
function M.on_attach(keymap_spec, buffer)
	if not keymap_spec then
		return
	end

	for _, keys in ipairs(keymap_spec) do
		-- 1. Check 'has' capability
		local has_capability = not keys.has or M.has(buffer, keys.has)

		-- 2. Check 'cond' function
		local is_cond_met = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

		-- 3. If both pass, set the keymap
		if has_capability and is_cond_met then
			local mode, lhs, rhs, opts = parse_key_spec(keys)

			if mode and lhs and rhs and opts then
				opts.buffer = buffer -- This is crucial! Makes the keymap buffer-local.
				vim.keymap.set(mode, lhs, rhs, opts)
			end
		end
	end
end

return M
