return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      log_level = "error",
      auto_restore_enabled = false,
      auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      session_lens = {
        -- If load_on_setup is set to false, one needs to eventually call `require("auto-session").setup_session_lens()` if they want to use session-lens.
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
        buftypes_to_ignore = {}, -- list of buffer types that should not be deleted from current session when a new one is loaded
      },
    })

    vim.keymap.set("n", "<leader>wl", require("auto-session.session-lens").search_session, { desc = "List Sessions" }) -- list all saved sessions
    vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
    vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
  end,
}
