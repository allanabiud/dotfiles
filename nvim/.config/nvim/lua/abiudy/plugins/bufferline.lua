return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers", -- set to "tabs" to only show tabpages instead
        numbers = "ordinal",
        separator_style = "slant",
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer", -- You can customize the title here
            text_align = "center",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    })
  end,
}
