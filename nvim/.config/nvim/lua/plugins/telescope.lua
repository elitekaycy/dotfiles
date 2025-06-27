return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  opts = {
    defaults = {
      layout_strategy = "flex",
      layout_config = { width = 0.95 },
      path_display = { "smart" },
    },
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>" },
  },
}
