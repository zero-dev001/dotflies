return {
  "stevearc/conform.nvim",
  opts = {
    -- Format on focus lost instead of on save
    format_on_save = false,
    format_after_save = false,
  },
  init = function()
    -- Format when leaving the buffer
    vim.api.nvim_create_autocmd("BufLeave", {
      callback = function(args)
        if vim.bo[args.buf].modified then
          require("conform").format({ bufnr = args.buf, async = true, lsp_fallback = true })
        end
      end,
    })
  end,
}
