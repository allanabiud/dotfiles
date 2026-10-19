return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.buttons.val = {
      dashboard.button("SPC s f", "󰈞  Search files", "<cmd>Telescope find_files<CR>"),
      dashboard.button("SPC s .", "󰊄  Search recent files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("SPC s g", "󰈬  Search by grep", "<cmd>Telescope live_grep<CR>"),
      dashboard.button(
        "SPC s n",
        "  Search Neovim files",
        '<cmd>lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })<CR>'
      ),
      dashboard.button("l", "󰒲  Lazy plugin manager", "<cmd>Lazy<CR>"),
      dashboard.button("s", "  Restore session", "<cmd>AutoSession restore<CR>"),
      dashboard.button("\\", "  Toggle file explorer", "<cmd>Neotree toggle<CR>"),
      dashboard.button("q", "󰗼  Quit Neovim", "<cmd>qa<CR>"),
    }

    alpha.setup(dashboard.config)
  end,
}
