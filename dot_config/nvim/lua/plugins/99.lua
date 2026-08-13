return {
  {
    dir = vim.fn.expand("~/Developer/zero/workspace/99"),
    config = function()
      require("99").setup({
        provider = require("99.providers").ClaudeCodeProvider,
        model = "opus-4.6",
      })
    end,
    keys = {
      {
        "<leader>mm",
        function()
          require("99").select_model()
        end,
        desc = "Select AI model",
      },
      {
        "<leader>9v",
        function()
          require("99").visual()
        end,
        mode = "v",
        desc = "99 AI visual",
      },
      {
        "<leader>9s",
        function()
          require("99").stop_all_requests()
        end,
        desc = "99 Stop all requests",
      },
    },
  },
}
