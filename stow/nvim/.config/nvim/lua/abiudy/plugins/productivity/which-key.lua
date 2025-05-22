return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")

      wk.add({
        -- Define a group for file-related actions
        { "<leader>c", group = "Code Actions" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "Lazygit" },
        { "<leader>M", group = "Markdown" },
        { "<leader>r", group = "Restart/Rename" },
        { "<leader>s", group = "Search" },
        { "<leader>S", group = "Snacks" },
        { "<leader>t", group = "Tools" },
        { "<leader>tl", group = "Live Preview" },
        { "<leader>tf", group = "Flutter Tools" },
        { "<leader>w", group = "Workspace Sessions" },
      })
    end,
  },
}
