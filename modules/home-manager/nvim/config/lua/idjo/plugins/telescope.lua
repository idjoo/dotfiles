return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			enabled = vim.fn.executable("make") == 1,
			opts = {
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					},
				},
			},
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		-- command
		{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },

		-- files
		{ "<leader>fg", "<cmd>Telescope live_grep <CR>", desc = "Live Grep" },
		{ "<leader>ff", "<cmd>Telescope find_files <CR>", desc = "Find Files" },

		-- recents
		{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },

		-- buffers
		{ "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },

		-- registers
		{ '<leader>f"', "<cmd>Telescope registers<cr>", desc = "Registers" },

		-- keymaps
		{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
	},
	config = function(_, opts)
		return {
			defaults = {
				vimgrep_arguments = {
					"rg",
					"-L",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				prompt_prefix = "   ",
				selection_caret = "  ",
				entry_prefix = "  ",
				initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				file_ignore_patterns = { "node_modules" },
				-- generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				path_display = { "truncate" },
				winblend = 0,
				border = {},
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				color_devicons = true,
				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
				-- Developer configurations: Not meant for general override
				buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
				mappings = {
					n = { ["q"] = require("telescope.actions").close },
				},
			},

			extensions_list = { "themes", "terms" },
		}
	end,
}
