return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    keys = {
      { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Search open buffers" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Search help tags" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
      { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Search files" },
      { "<leader>ss", "<cmd>Telescope builtin<cr>", desc = "Search Telescope pickers" },
      { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Search current word" },
      { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search by grep" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Search diagnostics" },
      { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      { "<leader>s.", "<cmd>Telescope oldfiles<cr>", desc = "Search recent files" },
      { "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      {
        "<leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "Search in current buffer",
      },
      {
        "<leader>s/",
        function()
          require("telescope.builtin").live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end,
        desc = "Search in open files",
      },
      {
        "<leader>sn",
        function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Search Neovim files",
      },
    },
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
    end,
  },
}
