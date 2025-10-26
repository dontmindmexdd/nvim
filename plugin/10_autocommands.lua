-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
-- There are other autocommands created by 'mini.basics'.
local f = function() vim.cmd("setlocal formatoptions-=c formatoptions-=o") end
_G.Config.new_autocmd("FileType", nil, f, "Proper 'formatoptions'")

_G.Config.new_autocmd("VimResized", nil, function()
	local current_tab = vim.fn.tabpagenr()
	vim.cmd("tabdo wincmd =")
	vim.cmd("tabnext " .. current_tab)
end, "Autoresize windows")

_G.Config.new_autocmd({ "FocusGained", "TermClose", "TermLeave" }, nil, function()
	if vim.o.buftype ~= "nofile" then
		vim.cmd("checktime")
	end
end, "Check if file needs reloading")

_G.Config.new_autocmd(
	"FileType",
	{ "man" },
	function(event) vim.bo[event.buf].buflisted = false end,
	"Make it easier to close man-files when opened inline"
)

_G.Config.new_autocmd(
	{ "FileType" },
	{ "json", "jsonc", "json5" },
	function() vim.opt_local.conceallevel = 0 end,
	"Fix conceallevel for json files"
)
