-- Load with dofile('/path/to/tidalcycles-kit/editors/tidal.nvim.lua').
-- Install grddavies/tidal.nvim with your preferred plugin manager first.
local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h')
require('tidal').setup({
  boot = {
    tidal = {
      cmd = root .. '/bin/tidal-ghci',
      args = { '-v0' },
      file = root .. '/runtime/BootTidal.hs',
    },
    sclang = { enabled = false },
  },
})
