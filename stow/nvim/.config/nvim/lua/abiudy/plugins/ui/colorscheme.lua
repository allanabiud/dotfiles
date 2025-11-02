return {
  "olimorris/onedarkpro.nvim",
  event = "VimEnter",
  priority = 1000, -- Ensure it loads first
  config = function()
    require("onedarkpro").setup({
      colors = {
        dark = { bg = "#050505" },
      },
      options = {
        transparency = false,
      },
      highlights = {
        Comment = { italic = true, fg = "#a3a6ad" },
        Directory = { bold = true },
        ErrorMsg = { italic = true, bold = true },
      },
    })
    vim.cmd("colorscheme onedark_dark")
  end,
}
