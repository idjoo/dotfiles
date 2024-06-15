-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "tolol"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "tolol"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "tolol"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "tolol"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- LSP
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "LSP definition" })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "LSP hover" })
vim.keymap.set("n", "<leader>D", function() vim.lsp.buf.type_definition() end, { desc = "LSP definition type" })
vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, { desc = "LSP references" })
