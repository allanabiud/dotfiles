-- Supermaven
return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<A-Enter>",
        clear_suggestion = "<A-k>",
        accept_word = "<A-l>",
      },
      ignore_filetypes = {
        "neo-tree",
        -- "cpp"
      },
      color = {
        suggestion_color = "#9e5b03",
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    })
  end,
}
