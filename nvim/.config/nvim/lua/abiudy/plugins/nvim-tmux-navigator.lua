return {
  "christoomey/vim-tmux-navigator",
  vim.keymap.set("n", "<c-left>", ":TmuxNavigateLeft<cr>"),
  vim.keymap.set("n", "<c-right>", ":TmuxNavigateRight<cr>"),
  vim.keymap.set("n", "<c-down>", ":TmuxNavigateDown<cr>"),
  vim.keymap.set("n", "<c-up>", ":TmuxNavigateUp<cr>"),
}
