-- lua/plugins/asciidoc.lua
return {
  {
    "habamax/vim-asciidoctor",
    ft = "asciidoctor",
    init = function()
      -- Neovim detects .adoc as "asciidoc"; force the filetype this plugin expects.
      vim.filetype.add({ extension = { adoc = "asciidoctor", asciidoc = "asciidoctor" } })
      vim.g.asciidoctor_folding = 1 -- optional: fold sections

      vim.g.asciidoctor_pdf_themes_path = vim.fn.expand("~/docs/AsciiDocThemes")
      vim.g.asciidoctor_pdf_fonts_path = vim.fn.expand("~/docs/AsciiDocThemes/fonts")
    end,
    keys = {
      {
        "<localleader>r",
        function()
          vim.cmd("write")
          vim.cmd("Asciidoctor2HTML")
          vim.cmd("AsciidoctorOpenHTML")
        end,
        ft = "asciidoctor",
        desc = "Render AsciiDoc to HTML and open it",
      },
      { "<localleader>h", "<cmd>Asciidoctor2HTML<cr>", ft = "asciidoctor", desc = "Render to HTML" },
      { "<localleader>o", "<cmd>AsciidoctorOpenHTML<cr>", ft = "asciidoctor", desc = "Open rendered HTML" },
      {
        "<localleader>R",
        function()
          vim.cmd("write")
          vim.cmd("Asciidoctor2PDF")
          vim.cmd("AsciidoctorOpenPDF")
        end,
        ft = "asciidoctor",
        desc = "Render AsciiDoc to PDF and open it",
      },
      { "<localleader>p", "<cmd>Asciidoctor2PDF<cr>", ft = "asciidoctor", desc = "Render to PDF" },
    },
  },
}
