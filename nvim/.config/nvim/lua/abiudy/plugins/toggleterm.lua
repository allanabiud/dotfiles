return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 10,
      open_mapping = [[<c-\>]],
      close_on_exit = true,
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "horizontal",
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })

    function _G.set_terminal_keymaps()
      local opts = { noremap = true }
      vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
    end

    -- if you only want these mappings for toggleterm-buffers, use term://*toggleterm#*
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    -- allow wqa to quit the terminal using the following autocmd
    vim.api.nvim_create_autocmd({ "TermEnter" }, {
      callback = function()
        for _, buffers in ipairs(vim.fn.getbufinfo()) do
          local filetype = vim.api.nvim_buf_get_option(buffers.bufnr, "filetype")
          if filetype == "toggleterm" then
            vim.api.nvim_create_autocmd({ "BufWriteCmd", "FileWriteCmd", "FileAppendCmd" }, {
              buffer = buffers.bufnr,
              command = "q!",
            })
          end
        end
      end,
    })
  end,
}
