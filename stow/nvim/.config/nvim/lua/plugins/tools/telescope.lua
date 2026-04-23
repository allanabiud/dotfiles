return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
      {
        "nvim-telescope/telescope-ui-select.nvim",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#dac7ff", bg = "#151218" })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#a5ffb9", bg = "#151218" })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#dac7ff", bg = "#151218" })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#e0d1ff", bg = "#151218" })
      vim.api.nvim_set_hl(0, "TelescopeTitle", { fg = "#151218", bg = "#dac7ff", bold = true })
      vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = "#faf8ff", bg = "#1d1a21" })
      vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = "#a5ffb9", bg = "#1d1a21", bold = true })
      vim.api.nvim_set_hl(0, "TelescopePromptCounter", { fg = "#9c98a4", bg = "#1d1a21" })
      vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#151218", bg = "#a5ffb9", bold = true })
      vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { fg = "#faf8ff", bg = "#151218" })
      vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { fg = "#faf8ff", bg = "#151218" })

      telescope.setup({
        defaults = {
          path_display = { "tail" },
          sorting_strategy = "ascending",
          border = true,
          borderchars = {
            prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          },
          winblend = 0,
          layout_config = {
            prompt_position = "top",
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<C-d>"] = actions.delete_buffer,
            },
            n = {
              ["d"] = actions.delete_buffer,
              ["q"] = actions.close,
            },
          },
        },
        -- pickers = {}
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      -- telescope.load_extension("flutter")

      local keymap = vim.keymap
      local builtin = require("telescope.builtin")

      keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search open buffers" })
      keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help tags" })
      keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
      keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search files" })
      keymap.set("n", "<leader>ss", builtin.builtin, { desc = "Search Telescope pickers" })
      keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current word" })
      keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by grep" })
      keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search diagnostics" })
      keymap.set("n", "<leader>sr", builtin.resume, { desc = "Resume last search" })
      keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Search recent files" })
      keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })

      -- Git
      keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
      keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
      keymap.set("n", "<leader>gs", builtin.git_status, { desc = "Git status" })

      -- Slightly advanced example of overriding default behavior and theme
      keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Search in current buffer" })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "Search in open files" })

      -- Shortcut for searching Neovim configuration files
      keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "Search Neovim files" })
    end,
  },
}
