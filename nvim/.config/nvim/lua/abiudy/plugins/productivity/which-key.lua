return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy", -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      local wk = require("which-key")

      wk.add({
        -- Define a group for file-related actions
        { "<leader>b", group = "Buffer Actions" },
        { "<leader>c", group = "Code Actions" },
        { "<leader>f", group = "Formatting" },
        { "<leader>F", group = "Flutter Tools" },
        { "<leader>l", group = "Live Preview" },
        { "<leader>n", group = "No Highlight" },
        { "<leader>o", group = "Obsidian" },
        { "<leader>r", group = "Restart/Rename" },
        { "<leader>s", group = "Search with Telescope" },
        { "<leader>S", group = "Snacks Tools" },
        { "<leader>w", group = "Workspace Sessions" },
      })
    end,
  },
}
