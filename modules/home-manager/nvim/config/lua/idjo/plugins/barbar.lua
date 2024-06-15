return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
		"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = {
		animation = true,
		auto_hide = false,
	},
	keys = {
		{ "]b", "<cmd>BufferNext<cr>", desc = "Next buffer" },
		{ "[b", "<cmd>BufferPrevious<cr>", desc = "Previous buffer" },
	},
}
