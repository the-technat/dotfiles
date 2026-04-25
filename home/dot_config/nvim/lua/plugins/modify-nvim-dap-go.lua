return {
  -- always use remote output to show logs in nvim's DAPR
  -- this way we don't have to set this in launch.json for every programm
  "leoluz/nvim-dap-go",
  opts = {
    outputMode = "remote",
  },
}
