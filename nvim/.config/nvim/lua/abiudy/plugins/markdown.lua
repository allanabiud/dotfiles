return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    {
      -- Install markdown preview, use npx if available.
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = function(plugin)
        if vim.fn.executable("npx") then
          vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
        else
          vim.cmd([[Lazy load markdown-preview.nvim]])
          vim.fn["mkdp#util#install"]()
        end
      end,
      init = function()
        if vim.fn.executable("npx") then
          vim.g.mkdp_filetypes = { "markdown" }
        end
      end,
    },
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.nvim",
    "nvim-tree/nvim-web-devicons",
  }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  config = function()
    require("render-markdown").setup({})
  end,
}
