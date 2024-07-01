return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy", -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require("which-key").setup()
      require("which-key").register({
        ["<leader>c"] = { name = "[c]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[d]iagnostics", _ = "which_key_ignore" },
        ["<leader>f"] = { name = "[f]ormat", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "Git [h]unk", _ = "which_key_ignore" },
        ["<leader>l"] = { name = "[l]int", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[r]ename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "[s]earch", _ = "which_key_ignore" },
        ["<leader>t"] = { name = "[t]oggle", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[w]orkspace", _ = "which_key_ignore" },
        --["<leader>x"] = { name = "[S]plit", _ = "which_key_ignore" },
        ["<leader>R"] = { name = "[R]un", _ = "which_key_ignore" },
        ["<leader>T"] = { name = "[T]odo", _ = "which_key_ignore" },
        ["<leader>L"] = { name = "[L]azygit", _ = "which_key_ignore" },
      })
      -- visual mode
      require("which-key").register({
        ["<leader>h"] = { "Git [H]unk" },
      }, { mode = "v" })
    end,
  },
}
