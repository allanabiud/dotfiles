-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Associate Django template files with htmldjango filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = {
    "*/templates/*.html",
    "*/templates/*/*.html",
  },
  command = "set filetype=htmldjango",
})

-- Associate EJS files with ejs filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*/views/*.ejs" },
  command = "set filetype=ejs",
})

-- Hyprlang LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.hl", "hypr*.conf", "hypr/*.conf" },
  callback = function(event)
    print(string.format("starting hyprls for %s", vim.inspect(event)))
    vim.lsp.start({
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
    })
  end,
})

-- Godot Project Listener
local gdproject = io.open(vim.fn.getcwd() .. "/project.godot", "r")
if gdproject then
  io.close(gdproject)
  local socket = vim.fn.getcwd() .. "/.godothost"
  pcall(vim.fn.serverstart, socket)
end

-- Unity Project Listener
local cwd = vim.fn.getcwd()
local assets = io.open(cwd .. "/Assets", "r")
local project_settings = io.open(cwd .. "/ProjectSettings", "r")

if assets and project_settings then
  io.close(assets)
  io.close(project_settings)

  local socket = "/tmp/nvimsocket"
  pcall(vim.fn.serverstart, socket)
end
