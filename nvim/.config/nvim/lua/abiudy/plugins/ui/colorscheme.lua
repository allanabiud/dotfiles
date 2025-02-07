return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  config = function()
    require("onedarkpro").setup({
      highlights = {
        Comment = { italic = true, fg = "#a3a6ad" },
        Directory = { bold = true },
        ErrorMsg = { italic = true, bold = true },
      },
    })
    vim.cmd("colorscheme onedark_dark")
  end,
}
