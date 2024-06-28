-- solarized colorscheme
-- https://github.com/maxmx03/solarized.nvim

return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme 'solarized'
  end,
}
