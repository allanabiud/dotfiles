return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false,
      log_level = "error",
      session_lens = {
        buftypes_to_ignore = {},
        load_on_setup = true,
        previewer = false,
        theme_conf = {
          border = true,
        },
      },
      suppressed_dirs = { "~/", "~/DEV", "~/Downloads", "~/Documents", "~/Desktop/" },
    })

    vim.keymap.set("n", "<leader>wl", require("auto-session.session-lens").search_session, { desc = "List Sessions" }) -- list all saved sessions
    vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
    vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
  end,
}
