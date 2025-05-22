return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Default dashboard
    -- alpha.setup(require("alpha.themes.startify").config)

    -- Customize dashboard
    -- Set header
    dashboard.section.header.val = {
      [[                               __                ]],
      [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("n", "󰝒  > New File", "<cmd>ene<CR>"),
      dashboard.button("\\", "  > Toggle file explorer", "<cmd>:Neotree filesystem reveal left<CR>"),
      dashboard.button("f", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("r", "󱋡  > Recent Files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("s", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
      dashboard.button("l", "󰒲  > Lazy", "<cmd>Lazy<CR>"),
      dashboard.button("q", "  > Quit", "<cmd>qa<CR>"),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
