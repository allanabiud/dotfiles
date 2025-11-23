return {
  {
    "uZer/pywal16.nvim",
    config = function()
      vim.cmd.colorscheme("pywal16")

      -- Make line highlight visible
      vim.api.nvim_set_hl(0, "CursorLine", { bg = "#333333" })
      -- Line number highlight
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })
      -- Override comment style
      vim.api.nvim_set_hl(0, "Comment", { italic = true })
      vim.api.nvim_set_hl(0, "TSComment", { italic = true })
    end,
  },
}
