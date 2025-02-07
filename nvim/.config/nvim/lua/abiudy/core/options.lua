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

-- Winbar
local colors = {
  blue = "#569cd6", -- Example blue
  red = "#f44747", -- Example red
  green = "#4c914c", -- Example green
  gray = "#6b6b6b", -- Example gray
  yellow = "#ffa500", -- Example yellow
}

vim.cmd(string.format([[highlight WinBar1 guifg=%s]], colors["yellow"]))
vim.cmd(string.format([[highlight WinBar2 guifg=%s]], colors["red"]))
vim.cmd(string.format([[highlight WinBar3 guifg=%s gui=bold]], colors["green"]))
-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
  local full_path = vim.fn.expand("%:p:h")
  return full_path:gsub(vim.fn.expand("$HOME"), "~")
end
-- Function to get the number of open buffers using the :ls command
local function get_buffer_count()
  local buffers = vim.fn.execute("ls")
  local count = 0
  -- Match only lines that represent buffers, typically starting with a number followed by a space
  for line in string.gmatch(buffers, "[^\r\n]+") do
    if string.match(line, "^%s*%d+") then
      count = count + 1
    end
  end
  return count
end
-- Function to update the winbar
local function update_winbar()
  local filetype = vim.bo.filetype

  -- Disable winbar for neo-tree
  if filetype == "neo-tree" then
    return
  end

  local home_replaced = get_winbar_path()
  local buffer_count = get_buffer_count()
  vim.opt.winbar = "%#WinBar1#%m "
    .. "%#WinBar2#("
    .. buffer_count
    .. ") "
    -- this shows the filename on the left
    .. "%#WinBar3#"
    .. vim.fn.expand("%:t")
    -- This shows the file path on the right
    .. "%*%=%#WinBar1#"
    .. home_replaced
end
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = update_winbar,
})
