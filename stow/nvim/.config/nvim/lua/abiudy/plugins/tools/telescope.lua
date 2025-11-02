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

      telescope.setup({
        defaults = {
          path_display = { "tail" },
          sorting_strategy = "ascending",
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

      keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [O]pen Buffers" })
      keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

      -- Git
      keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[G]it [C]ommits" })
      keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "[G]it [B]ranches" })
      keymap.set("n", "<leader>gs", builtin.git_status, { desc = "[G]it [S]tatus" })

      -- Slightly advanced example of overriding default behavior and theme
      keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch [/] in Open Files" })

      -- Shortcut for searching Neovim configuration files
      keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },
}
