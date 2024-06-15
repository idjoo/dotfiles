return {
	"lukas-reineke/indent-blankline.nvim",
	event = "BufReadPost",
	opts = {
		debounce = 100,
		indent = {
			char = "▎",
			smart_indent_cap = true,
		},

		whitespace = {
			highlight = {
				"Whitespace",
				"NonText",
			},
		},

		scope = {
			show_exact_scope = true,
		},

		viewport_buffer = {
			min = 1,
		},
	},

	config = function()
		require("ibl").setup()
	end,
}
