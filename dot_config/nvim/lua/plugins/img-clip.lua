return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
  },
  opts = {
    default = {
      embed_image_as_base64 = false,
      prompt_for_file_name = false,
      drag_and_drop = { insert_mode = true },
      use_absolute_path = false,
    },
  },
}
