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
      -- source_selector = {
      --   winbar = "Neo-tree",
      --   -- statusline = false,
      -- },
      source_selector = {
        winbar = true, -- toggle to show selector on winbar
        statusline = false, -- toggle to show selector on statusline
        show_scrolled_off_parent_node = false, -- this will replace the tabs with the parent path
        -- of the top visible node when scrolled down.
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "git_status" },
        },
        content_layout = "start", -- only with `tabs_layout` = "equal", "focus"
        --                start  : |/ 󰓩 bufname     \/...
        --                end    : |/     󰓩 bufname \/...
        --                center : |/   󰓩 bufname   \/...
        tabs_layout = "equal", -- start, end, center, equal, focus
        --             start  : |/  a  \/  b  \/  c  \            |
        --             end    : |            /  a  \/  b  \/  c  \|
        --             center : |      /  a  \/  b  \/  c  \      |
        --             equal  : |/    a    \/    b    \/    c    \|
        --             active : |/  focused tab    \/  b  \/  c  \|
        truncation_character = "…", -- character to use when truncating the tab label
        tabs_min_width = nil, -- nil | int: if int padding is added based on `content_layout`
        tabs_max_width = nil, -- this will truncate text even if `text_trunc_to_fit = false`
        padding = 0, -- can be int or table
        -- padding = { left = 2, right = 0 },
        -- separator = "▕", -- can be string or table, see below
        separator = { left = "▏", right = "▕" },
        -- separator = { left = "/", right = "\\", override = nil },     -- |/  a  \/  b  \/  c  \...
        -- separator = { left = "/", right = "\\", override = "right" }, -- |/  a  \  b  \  c  \...
        -- separator = { left = "/", right = "\\", override = "left" },  -- |/  a  /  b  /  c  /...
        -- separator = { left = "/", right = "\\", override = "active" },-- |/  a  / b:active \  c  \...
        -- separator = "|",                                              -- ||  a  |  b  |  c  |...
        separator_active = nil, -- set separators around the active tab. nil falls back to `source_selector.separator`
        show_separator_on_edge = false,
        --                       true  : |/    a    \/    b    \/    c    \|
        --                       false : |     a    \/    b    \/    c     |
        highlight_tab = "NeoTreeTabInactive",
        highlight_tab_active = "NeoTreeTabActive",
        highlight_background = "NeoTreeTabInactive",
        highlight_separator = "NeoTreeTabSeparatorInactive",
        highlight_separator_active = "NeoTreeTabSeparatorActive",
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
        width = 30,
        mappings = {
          ["\\"] = "close_window",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
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
          position = "left",
          float = false,
        },
      },
    })
    vim.keymap.set("n", "\\", ":Neotree filesystem reveal left<CR>", {})
    vim.keymap.set("n", "1", ":Neotree source=filesystem<CR>", { silent = true })
    vim.keymap.set("n", "2", ":Neotree source=buffers<CR>", { silent = true })
    vim.keymap.set("n", "3", ":Neotree source=git_status<CR>", { silent = true })
  end,
}
