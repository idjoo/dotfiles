-------------------------------------- options ------------------------------------------
vim.cmd.colorscheme("catppuccin-mocha")

vim.opt.laststatus = 3 -- global statusline
vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = false

-- Indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.fillchars = { eob = " " }
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Numbers
vim.opt.number = true
vim.opt.numberwidth = 1
vim.opt.ruler = false

-- disable nvim intro
-- vim.opt.shortmess:append "sI"

vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
vim.opt.updatetime = 250

-- Foldings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

vim.opt.guicursor = "n-v-c-i:block"
vim.opt.wrap = false
vim.opt.scrolloff = 10

-- Enable break indent
vim.opt.breakindent = true

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
-- vim.opt.list = true
-- vim.opt.listchars = {
--   trail = '·', nbsp = '␣'
-- }

vim.cmd([[packadd justify]])
