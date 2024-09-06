return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  -- lazy = true,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    -- refer to `:h file-pattern` for more examples
    "BufReadPre "
      .. vim.fn.expand("~")
      .. "/Documents/Obsidian Vault/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Obsidian Vault/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("obsidian").setup({
      ui = {
        enable = false,
      },
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/Obsidian Vault/",
        },
        -- {
        -- name = "work",
        -- path = "~/vaults/work",
        -- },
      },
    })
  end,
}
