return {
	"nvim-pack/nvim-spectre",
	build = false,
	cmd = "Spectre",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = { open_cmd = "noswapfile vnew" },
  -- stylua: ignore
  keys = {
    { "<leader>sr", function() require("spectre").toggle() end, desc = "Replace in files (Spectre)" },
  },
}
