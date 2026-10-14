return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>fH",
        function()
          require("telescope.builtin").find_files({
            cwd = vim.fn.expand("~"),
            hidden = true,
          })
        end,
        desc = "Find Files (Home)",
      },
    },
  },
}
``
