return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- Use tofu for terraform files
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        hcl = { "tfmt" },
        tf = { "tfmt" },
        terraform = { "tfmt" },
        ["terraform-vars"] = { "tfmt" },
      },
      formatters = {
        tfmt = {
          -- Specify the command and its arguments for formatting
          command = "tofu",
          args = { "fmt", "-" },
          stdin = true,
        },
      },
    },
  },

  -- add any tools you want to have installed below
  {
    "mason-org/mason.nvim",
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
        "ltex-ls-plus", -- language server for LanguageTool with support for LaTeX, Markdown, and others
      },
    },
  },

  -- -- Helper for ltex-ls which provides e.g. "add to dictionary"
  -- {
  --   "barreiroleo/ltex_extra.nvim",
  --   ft = { "markdown", "tex" },
  --   dependencies = { "neovim/nvim-lspconfig" },
  --   -- yes, you can use the opts field, just I'm showing the setup explicitly
  --   config = function()
  --     require("ltex_extra").setup({
  --       {},
  --       server_opts = {
  --         capabilities = {},
  --         on_attach = function(client, bufnr)
  --           -- your on_attach process
  --         end,
  --         settings = {
  --           ltex = {},
  --         },
  --       },
  --     })
  --   end,
  -- },

  -- set dark mode from system
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 5000,
      fallback = "light",
    },
  },

  -- break bad habits, master vim motions
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
}
