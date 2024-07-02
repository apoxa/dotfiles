-- Persist and toggle terminals
-- https://github.com/akinsho/toggleterm.nvim

return {
  'numToStr/FTerm.nvim',
  keys = {
    { '<c-q>', '<CMD>lua require("FTerm").toggle()<CR>', mode = { 'n', 't' }, desc = 'Toggle Terminal' },
  },
}
