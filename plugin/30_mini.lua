local now, later = MiniDeps.now, MiniDeps.later

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

now(function()
	local sessions = require("mini.sessions")
	sessions.setup()

	_G.Config.new_autocmd("VimLeavePre", "*", function()
		local existing = MiniSessions.detected

		if next(existing) == nil then
			MiniSessions.write("Session")
		elseif next(existing) then
			MiniSessions.write()
		end
	end)
end)

now(function()
	local starter = require("mini.starter")
	starter.setup({
		evaluate_single = true,
		items = {
			starter.sections.builtin_actions(),
			starter.sections.recent_files(10, true),
			-- Use this if you set up 'mini.sessions'
			starter.sections.sessions(5, true),
		},
		content_hooks = {
			starter.gen_hook.adding_bullet(),
			starter.gen_hook.indexing("all", { "Builtin actions" }),
			starter.gen_hook.padding(3, 2),
		},
	})
end)
