vim.cmd("let g:netrw_liststyle = 3")

-- Make line numbers default
vim.opt.number = true

-- Set title
vim.opt.title = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Set Tab and Indent Behaviour
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.breakindent = true
-- vim.opt.softtabstop = 2
-- vim.opt.smarttab = true
-- vim.opt.smartindent = true

-- Set wrap behaviour
vim.opt.wrap = true
vim.opt.linebreak = true

-- Set folding behaviour
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- Enable termguicolors
vim.opt.termguicolors = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Ensure lualine is a global statusline
vim.o.laststatus = 3

-- Enable winbar
vim.o.winbar = "%=%f"
