-- modifis the debugging UI, where infos can be found and whether the UI closes / opens when a session ends or starts
return {
  "rcarriga/nvim-dap-ui",
  keys = {
    -- show scopes as floating window under my cursor
    {
      "<leader>dv",
      function()
        require("dapui").float_element("scopes", { enter = true })
      end,
      desc = "Toggle Scopes (floating)",
    },
    {
      "<leader>dl",
      function()
        require("dapui").float_element("console")
      end,
      desc = "Toggle Console (floating)",
    },
  },
  --- https://github.com/rcarriga/nvim-dap-ui/issues/201
  config = function(_, opts)
    local dap = require("dap")
    local dapui = require("dapui")
    dapui.setup(opts)
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
  end,
  -- inspiration: https://github.com/rcarriga/nvim-dap-ui/issues/429#issuecomment-2629045405
  opts = {
    layouts = {
      {
        elements = {
          -- elements can be strings or table with id and size keys.
          { id = "scopes", size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 0.1, -- 10% of total columns
        position = "right",
      },
      {
        elements = {
          { id = "console", size = 1 },
        },
        size = 0.25, -- 25% of total lines
        position = "bottom",
      },
    },
  },
}
