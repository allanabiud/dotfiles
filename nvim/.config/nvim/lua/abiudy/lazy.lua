local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- { import = "abiudy.plugins" },
  { import = "abiudy.plugins.AI" },
  { import = "abiudy.plugins.format-and-lint" },
  { import = "abiudy.plugins.lsp" },
  { import = "abiudy.plugins.navigation" },
  { import = "abiudy.plugins.productivity" },
  { import = "abiudy.plugins.tools" },
  { import = "abiudy.plugins.tools.framework" },
  { import = "abiudy.plugins.ui" },
}, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  ui = {
    border = "rounded",
  },
})
