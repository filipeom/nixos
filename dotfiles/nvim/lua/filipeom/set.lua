-- vim.opt.guicursor = ''

vim.opt.nu = true
vim.opt.relativenumber = false
vim.opt.cursorline = false

vim.o.winborder = 'rounded'

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("XDG_DATA_HOME") .. "/nvim/undo"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "81"

vim.opt.foldlevel = 99

vim.g.mapleader = " "
