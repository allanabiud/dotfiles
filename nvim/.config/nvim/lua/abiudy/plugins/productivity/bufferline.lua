return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "buffers", -- set to "tabs" to only show tabpages instead
      numbers = "ordinal",
      separator_style = "thick",
      indicator = {
        icon = "▎", -- this should be omitted if indicator style is not 'icon'
        -- style = "underline",
      },
      buffer_close_icon = "󰅖",
      modified_icon = "● ",
      close_icon = " ",
      left_trunc_marker = " ",
      right_trunc_marker = " ",
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer", -- You can customize the title here
          text_align = "center",
          highlight = "Directory",
          separator = true,
        },
        separator_style = "thick",
        pick = {
          alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
        },
      },
    },
  },
  -- BufferLine Mappings
  -- Go To Buffer
  vim.keymap.set("n", "<leader>b1", ":BufferLineGoToBuffer 1<CR>", { desc = "Buffer 1" }),
  vim.keymap.set("n", "<leader>b2", ":BufferLineGoToBuffer 2<CR>", { desc = "Buffer 2" }),
  vim.keymap.set("n", "<leader>b3", ":BufferLineGoToBuffer 3<CR>", { desc = "Buffer 3" }),
  vim.keymap.set("n", "<leader>b4", ":BufferLineGoToBuffer 4<CR>", { desc = "Buffer 4" }),
  vim.keymap.set("n", "<leader>b5", ":BufferLineGoToBuffer 5<CR>", { desc = "Buffer 5" }),
  vim.keymap.set("n", "<leader>b6", ":BufferLineGoToBuffer 6<CR>", { desc = "Buffer 6" }),
  vim.keymap.set("n", "<leader>b7", ":BufferLineGoToBuffer 7<CR>", { desc = "Buffer 7" }),
  vim.keymap.set("n", "<leader>b8", ":BufferLineGoToBuffer 8<CR>", { desc = "Buffer 8" }),
  vim.keymap.set("n", "<leader>b9", ":BufferLineGoToBuffer 9<CR>", { desc = "Buffer 9" }),

  -- Cycle Buffers
  vim.keymap.set("n", "<A-.>", ":BufferLineCycleNext<CR>", { desc = "Cycle Buffers" }),
  vim.keymap.set("n", "<A-,>", ":BufferLineCyclePrev<CR>", { desc = "Cycle Buffers Reverse" }),

  -- Close Buffers
  vim.keymap.set("n", "<leader>bcr", ":BufferLineCloseRight<CR>", { desc = "Close Buffers to the Right" }),
  vim.keymap.set("n", "<leader>bcl", ":BufferLineCloseLeft<CR>", { desc = "Close Buffers to the Left" }),
  vim.keymap.set("n", "<leader>bco", ":BufferLineCloseOthers<CR>", { desc = "Close Other Buffers" }),
  vim.keymap.set("n", "<leader>bcp", ":BufferLinePickClose<CR>", { desc = "Pick Buffers to Close" }),
}
