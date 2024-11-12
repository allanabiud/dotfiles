vim.cmd("let g:netrw_liststyle = 3")

-- Make line numbers default
vim.opt.number = true
-- vim.opt.relativenumber = true

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
--vim.opt.smarttab = true
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

-- Sets how neovim will display certain whitespace characters in the editor.
--vim.opt.list = true
--vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Ensure lualine is a global statusline
vim.o.laststatus = 3

-- Define custom highlight groups for WinBar1 and WinBar2 with specific colors
vim.cmd("highlight WinBar1 guifg=#FFD700 gui=bold") -- Gold color for modified status
vim.cmd("highlight WinBar2 guifg=#00FF00") -- Green color for buffer count

-- Function to get the full path and replace the home directory with ~
local function get_winbar_path()
  local full_path = vim.fn.expand("%:p")
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
  if vim.bo.buftype == "" and vim.bo.filetype ~= "neo-tree" then
    local home_replaced = get_winbar_path()
    local buffer_count = get_buffer_count()
    vim.wo.winbar = "%#WinBar1#%m "
      .. "%#WinBar2#("
      .. buffer_count
      .. ") "
      .. "%#WinBar1#"
      .. home_replaced
      .. "%*%=%#WinBar2#"
  else
    -- Do nothing for Neo-tree, allowing it to manage its winbar independently
  end
end
-- vim.opt.winbar = "%#WinBar1#%m "
--   .. "%#WinBar2#("
--   .. buffer_count
--   .. ") "
--   .. "%#WinBar1#"
--   .. home_replaced
--   .. "%*%=%#WinBar2#"
-- I don't need the hostname as I have it in lualine
-- .. vim.fn.systemlist("hostname")[1]
-- Autocmd to update the winbar on BufEnter and WinEnter events
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = update_winbar,
  pattern = "*",
})
