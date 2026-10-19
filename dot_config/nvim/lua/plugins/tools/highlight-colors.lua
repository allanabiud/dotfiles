return {
  "brenoprata10/nvim-highlight-colors",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-highlight-colors").setup({
      render = "background",
      --virtual_symbol = '■', -- need render to be set to virtual
      --virtual_symbol_position = 'inline', -- need render to be set to virtual
    })
  end,
}
