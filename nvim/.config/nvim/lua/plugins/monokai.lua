return {
  -- add gruvbox
  { "cpea2506/one_monokai.nvim" },

  config = function()
    require("one_monokai").setup({
      transparent = true, -- enable transparent window
      colors = {
        lmao = "#ffffff", -- add new color
        pink = "#ec6075", -- replace default color
      },
      themes = function(colors)
        -- change highlight of some groups,
        -- the key and value will be passed respectively to "nvim_set_hl"
        return {
          Normal = { bg = colors.lmao },
          DiffChange = { fg = colors.white:darken(0.3) },
          ErrorMsg = { fg = colors.pink, standout = true },
          ["@lsp.type.keyword"] = { link = "@keyword" },
        }
      end,
      italics = false, -- disable italics
    })
  end,
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "one_monokai",
    },
  },
}
