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
  },
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
