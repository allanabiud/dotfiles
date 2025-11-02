return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>ws", "<cmd>AutoSession search<CR>", desc = "AutoSession Search" },
    { "<leader>wr", "<cmd>AutoSession restore<CR>", desc = "AutoSession Restore" },
  },
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false,
      auto_save = true,
      bypass_save_filetypes = { "alpha" },
      log_level = "error",
      session_lens = {
        picker = telescope,
        load_on_setup = true,
        picker_opts = {
          border = true,
        },
      },
    })
  end,
}
