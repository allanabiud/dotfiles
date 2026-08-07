return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")

      wk.setup({
        win = {
          border = "rounded",
        },
      })

      -- Groups are derived from the actual `<leader>` prefixes used below.
      -- Icons are explicit nerd-font glyphs (passing a plain string would be
      -- treated as a filetype lookup, so we pass `{ icon = ... }` instead).
      wk.add({
        -- Groups
        { "<leader>c", group = "Code", icon = { icon = "󰌹", color = "orange" } },
        { "<leader>g", group = "Git", icon = { icon = "󰊢", color = "orange" } },
        { "<leader>r", group = "LSP", icon = { icon = "󰒋", color = "azure" } },
        { "<leader>s", group = "Search", icon = { icon = "󰍉", color = "blue" } },
        { "<leader>S", group = "Snacks", icon = { icon = "󱥰", color = "purple" } },
        { "<leader>w", group = "Workspace", icon = { icon = "󰆼", color = "cyan" } },

        -- Standalone leader keys
        { "<leader>e", icon = { icon = "󰐊", color = "green" }, desc = "Run code" },
        { "<leader>1", icon = { icon = "󰉋", color = "yellow" }, desc = "File explorer" },
        { "<leader>2", icon = { icon = "󰆎", color = "yellow" }, desc = "Document symbols" },
        { "<leader>nh", icon = { icon = "󰌷", color = "grey" }, desc = "Clear search highlights" },
        { "<leader><leader>", icon = { icon = "󰈔", color = "cyan" }, desc = "Find buffers" },
        { "<leader>/", icon = { icon = "󰈞", color = "blue" }, desc = "Search in buffer" },
      })
    end,
  },
}
