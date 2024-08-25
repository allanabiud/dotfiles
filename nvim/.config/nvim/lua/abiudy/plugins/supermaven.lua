return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-Enter>",
        clear_suggestion = "<C-k>",
        accept_word = "<C-l>",
      },
      ignore_filetypes = {
        -- cpp = true,
      },
      color = {
        suggestion_color = "#b36500",
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    })
  end,
}
