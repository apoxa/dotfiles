return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "ruff",
        "ansible-language-server",
        "bash-language-server",
        "shellcheck",
        "shfmt",
        "marksman",
        "powershell-editor-services",
        "terraform-ls",
        "prettier",
        "vale",
        "cbfmt", -- format codeblocks in markdown
      },
    },
  },
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
    },
  },
  -- set dark mode from system
  -- https://github.com/f-person/auto-dark-mode.nvim

  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 5000,
      fallback = "light",
    },
  },
}
