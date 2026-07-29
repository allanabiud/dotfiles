return {
  "AvengeMedia/base46",
  priority = 1000,
  lazy = false,
  opts = {},

  config = function()
    require("base46").setup()
    vim.cmd.colorscheme("dms")
  end,
}
