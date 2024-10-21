-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Open a file in a new tab when opening a new file
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    -- Check if the buffer is a file and not a directory (or other non-editable buffers)
    if not vim.fn.isdirectory(bufname) and vim.bo.filetype ~= "neo-tree" then
      vim.cmd("tabedit %")
    end
  end,
})
