return {
  "CRAG666/code_runner.nvim",
  keys = {
    {
      "<leader>e",
      function()
        require("code_runner").run_code()
      end,
      desc = "Run code",
    },
  },
  config = function()
    local code_runner = require("code_runner")

    code_runner.setup({
      mode = "float",
      float = {
        close_key = "<ESC>",
        border = "single",
        border_hl = "FloatBorder",
      },
      startinsert = true,
      filetype = {
        python = "python -u $dir/$fileName",
        sh = "bash $file",
        html = "vivaldi $dir/$fileName",
        dart = "dart $file",
        javascript = "node $file",
        cs = "dotnet run",
      },
    })
  end,
}
