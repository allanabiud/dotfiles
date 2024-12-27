return {
  "CRAG666/code_runner.nvim",
  keys = {
    {
      "<leader>e",
      function()
        require("code_runner").run_code()
      end,
      desc = "[E]xcute code",
    },
  },
  config = function()
    local code_runner = require("code_runner")

    -- code_runner

    -- setup
    code_runner.setup({
      mode = "float",
      float = {
        close_key = "<ESC>",
        border = "single",
        border_hl = "FloatBorder",
      },
      startinsert = true,
      filetype = {
        python = "python3 -u $dir/$fileName",
        sh = "bash $file",
        html = "vivaldi $dir/$fileName",
        dart = "dart $file",
      },
    })

    -- keymaps
    -- vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { noremap = true, silent = false })
    -- vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
    -- vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })
    -- vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false })
    -- vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
    -- vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false })
    -- vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false })
  end,
}
