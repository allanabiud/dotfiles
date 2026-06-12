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

      local function setup_highlights()
        local base16 = require("base16-colorscheme").colors
        if not base16 then return end

        vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = base16.base0D, bg = base16.base00 })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = base16.base0B, bg = base16.base00 })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = base16.base0D, bg = base16.base00 })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = base16.base0E, bg = base16.base00 })
        vim.api.nvim_set_hl(0, "TelescopeTitle", { fg = base16.base00, bg = base16.base0D, bold = true })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = base16.base05, bg = base16.base01 })
        vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = base16.base0B, bg = base16.base01, bold = true })
        vim.api.nvim_set_hl(0, "TelescopePromptCounter", { fg = base16.base04, bg = base16.base01 })
        vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = base16.base00, bg = base16.base0B, bold = true })
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { fg = base16.base05, bg = base16.base00 })
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { fg = base16.base05, bg = base16.base00 })
      end

      setup_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup_highlights
      })

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
