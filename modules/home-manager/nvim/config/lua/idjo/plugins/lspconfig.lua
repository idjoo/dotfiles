return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"yamlls",
        "ansiblels",
        "terraformls",
        "jsonls",
        "nil_ls",
			},

			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
			},
		})
	end,
}

-- vim: ts=2 sts=2 sw=2 et
