return {
  "rcarriga/nvim-dap-ui",
  keys = {
    { "<leader>dv", "<cmd>lua require('dapui').float_element('scopes', {enter=true})<cr>" },
  },
  -- inspiration: https://github.com/rcarriga/nvim-dap-ui/issues/429#issuecomment-2629045405
  opts = {
    layouts = {
      {
        elements = {
          -- elements can be strings or table with id and size keys.
          { id = "scopes", size = 0.25 },
          "breakpoints",
          "stacks",
          "watches",
        },
        size = 40, -- 40 columns
        position = "right",
      },
      {
        elements = {
          "console",
        },
        size = 0.25, -- 25% of total lines
        position = "bottom",
      },
    },
  },
}
