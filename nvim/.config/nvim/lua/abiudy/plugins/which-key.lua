return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy", -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require("which-key").add({
        {
          "<leader>L",
          group = "[L]azygit",
        },
        {
          "<leader>L_",
          hidden = true,
        },
        {
          "<leader>c",
          group = "[c]ode",
        },
        {
          "<leader>c_",
          hidden = true,
        },
        {
          "<leader>d",
          group = "[d]iagnostics",
        },
        {
          "<leader>d_",
          hidden = true,
        },
        {
          "<leader>f",
          group = "[f]ormat",
        },
        {
          "<leader>f_",
          hidden = true,
        },
        {
          "<leader>h",
          group = "Git [h]unk",
        },
        {
          "<leader>h_",
          hidden = true,
        },
        {
          "<leader>l",
          group = "[l]int",
        },
        {
          "<leader>l_",
          hidden = true,
        },
        {
          "<leader>o",
          group = "[o]bsidian",
        },
        {
          "<leader>o_",
          hidden = true,
        },
        {
          "<leader>od",
          group = "[d]ailies",
        },
        {
          "<leader>od_",
          hidden = true,
        },
        {
          "<leader>of",
          group = "[f]ollow",
        },
        {
          "<leader>r",
          group = "[r]ename",
        },
        {
          "<leader>r_",
          hidden = true,
        },
        {
          "<leader>s",
          group = "[s]earch",
        },
        {
          "<leader>s_",
          hidden = true,
        },
        {
          "<leader>t",
          group = "[t]oggle",
        },
        {
          "<leader>t_",
          hidden = true,
        },
        {
          "<leader>w",
          group = "[w]orkspace",
        },
        {
          "<leader>w_",
          hidden = true,
        },
        -- visual mode
        {
          {
            "<leader>h",
            desc = "Git [H]unk",
            mode = "v",
          },
        },
      })
    end,
  },
}
