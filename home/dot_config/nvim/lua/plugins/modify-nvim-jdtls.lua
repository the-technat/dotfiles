return {
  -- https://github.com/LazyVim/LazyVim/discussions/2992
  "mfussenegger/nvim-jdtls",
  opts = {
    jdtls = function(opts)
      opts.settings = {
        java = {
          format = {
            enabled = true,
            settings = {
              url = vim.fn.expand("~/local/share/nvim/style.xml"),
              -- url = "https://github.com/google/styleguide/raw/refs/heads/gh-pages/intellij-java-google-style.xml",
              profile = "GoogleStyle",
            },
          },
        },
      }
      return opts
    end,
  },
}
