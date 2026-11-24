return {
  "yuukiflow/Arduino-Nvim",
  ft = "arduino",
  opts = {
    board = "esp32:esp32:esp32",
    port = "/dev/ttyUSB0",
    baudrate = 115200,
  },

  config = function(_, opts)
    local buf = vim.api.nvim_buf_get_name(0)
    if buf:match("%.ino$") then
      vim.fn.chdir(vim.fn.fnamemodify(buf, ":p:h"))
    end
    require("Arduino-Nvim").setup(opts)
  end,

  dependencies = {
    "nvim-telescope/telescope.nvim",
    "neovim/nvim-lspconfig",
  },
}
