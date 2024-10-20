return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    -- "mfussenegger/nvim-dap-python",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("dapui").setup()
    -- require("dap-python").setup("/home/abiudy/.virtualenvs/debugpy/bin/python")

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<Leader>dp", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<Leader>dn", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<Leader>ds", dap.step_out, { desc = "Step out" })
    vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Continue" })
  end,
}
