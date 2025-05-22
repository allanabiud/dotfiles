return {
  "cachebag/nvim-tcss",
  config = function()
    require("tcss").setup({
      enable = true,
    })

    -- Properties and values
    vim.api.nvim_set_hl(0, "tcssProperty", { fg = "#7DCFFF" }) -- Property names like width, height
    vim.api.nvim_set_hl(0, "tcssValue", { fg = "#BB9AF7" }) -- Values like "1", "2px", "bold"
    vim.api.nvim_set_hl(0, "tcssUnit", { fg = "#FF9E64" }) -- Units like px, em, %

    -- Variables and functions
    vim.api.nvim_set_hl(0, "tcssVariable", { fg = "#9ECE6A" }) -- Variable names
    vim.api.nvim_set_hl(0, "tcssFunction", { fg = "#F7768E" }) -- Function names

    -- Selectors and combinators
    vim.api.nvim_set_hl(0, "tcssSelector", { fg = "#2AC3DE" }) -- Class and ID selectors
    vim.api.nvim_set_hl(0, "tcssCombinator", { fg = "#E0AF68" }) -- Combinators like >, +

    -- Comments and special characters
    vim.api.nvim_set_hl(0, "tcssComment", { fg = "#565F89", italic = true }) -- Comments
    vim.api.nvim_set_hl(0, "tcssString", { fg = "#9ECE6A" }) -- String literals
    vim.api.nvim_set_hl(0, "tcssNumber", { fg = "#FF9E64" }) -- Numeric values

    -- Brackets and punctuation
    vim.api.nvim_set_hl(0, "tcssBraces", { fg = "#C0CAF5" }) -- Curly braces {}
    vim.api.nvim_set_hl(0, "tcssPunctuation", { fg = "#89DDFF" }) -- Colons, semicolons

    -- Special keywords
    vim.api.nvim_set_hl(0, "tcssKeyword", { fg = "#BB9AF7", bold = true }) -- Special keywords
    vim.api.nvim_set_hl(0, "tcssImportant", { fg = "#F7768E", bold = true }) -- !important

    -- States and pseudo-classes
    vim.api.nvim_set_hl(0, "tcssPseudoClass", { fg = "#7AA2F7" }) -- :hover, :active
    vim.api.nvim_set_hl(0, "tcssPseudoElement", { fg = "#7AA2F7" }) -- ::before, ::after

    -- Layout specific
    vim.api.nvim_set_hl(0, "tcssLayout", { fg = "#2AC3DE" }) -- Layout related properties
    vim.api.nvim_set_hl(0, "tcssPosition", { fg = "#7AA2F7" }) -- Position related properties

    -- Error highlighting
    vim.api.nvim_set_hl(0, "tcssError", { fg = "#F7768E", underline = true }) -- Syntax errors
  end,
}
