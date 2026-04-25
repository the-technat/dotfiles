return {
  -- disable markdown formatter by default
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = {},
    },
  },
}
