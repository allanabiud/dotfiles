return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      --close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      source_selector = {
        winbar = true,
        -- statusline = false,
      },
      default_component_configs = {
        indent = {
          padding = 0,
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "*",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
        },
        git_status = {
          symbols = {
            -- Change type
            added = "✚",
            modified = "",
            deleted = "✖",
            renamed = "",
            -- Status type
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
      window = {
        position = "left",
        width = 35,
        mappings = {
          ["\\"] = "close_window",
        },
      },
      filesystem = {
        --follow_current_file = true,
        --group_empty_dirs = true,
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true,
        -- cwd_target = "shortened",
      },
      --buffers = {
      --follow_current_file = true,
      --group_empty_dirs = true,
      --},
      git_status = {
        window = {
          position = "float",
        },
      },
    })
    vim.keymap.set("n", "\\", ":Neotree filesystem reveal left<CR>", {})
  end,
}
