-- init.lua for Neovim
-- This configuration uses lazy.nvim as the plugin manager.
-- It includes support for Rust and Golang via LSP, Treesitter for syntax highlighting,
-- Autocompletion, Telescope for search, and other useful plugins for programmers.

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 4           -- Tab width
vim.opt.shiftwidth = 4        -- Indent width
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.smartindent = true    -- Smart indenting
vim.opt.wrap = false          -- No line wrap
vim.opt.hlsearch = false      -- No highlight on search
vim.opt.incsearch = true      -- Incremental search
vim.opt.termguicolors = true  -- True color support
vim.opt.scrolloff = 8         -- Keep 8 lines above/below cursor
vim.opt.signcolumn = "yes"    -- Always show sign column
vim.opt.updatetime = 50       -- Faster update time
--vim.opt.colorcolumn = "80"    -- Column ruler at 80 chars

-- Install plugins with lazy.nvim
require("lazy").setup({
  -- Treesitter for syntax highlighting and more
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "rust", "go", "lua", "vim", "vimdoc", "query" },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = { enable = true },
      })
    end,
  },

  -- Treesitter Context (sticky headers for functions/classes)
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup()
    end,
  },

  -- LSP support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer", "gopls", "lua_ls" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
        },
      })

      -- Autocompletion setup
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, opts)
          vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
        end,
      })
    end,
  },

  -- Telescope for fuzzy finding and search
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
      vim.keymap.set("n", "<C-p>", builtin.git_files, {})
      vim.keymap.set("n", "<leader>ps", function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end)
      vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
      vim.keymap.set("n", "<leader>pb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>pd", builtin.diagnostics, {})

      -- Override for fuzzy symbol search (popup instead of bottom list)
      vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, {})
      vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, {})
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        actions = {
          open_file = {
            quit_on_open = false,  -- Explicitly keep tree open on file open
            window_picker = {
              enable = true,  -- Helps pick the window to open in
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({})
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    config = function()
      require("bufferline").setup({})
    end,
  },

  -- Nightfox theme
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        -- You can customize options here if needed, e.g., transparent background
        -- options = { transparent = true },
      })
    end,
  },
})

-- Additional keybindings
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Open netrw
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Move lines down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- Move lines up
vim.keymap.set("n", "J", "mzJ`z")             -- Join lines without moving cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz")       -- Half page down with centering
vim.keymap.set("n", "<C-u>", "<C-u>zz")       -- Half page up with centering
vim.keymap.set("n", "n", "nzzzv")             -- Next search with centering
vim.keymap.set("n", "N", "Nzzzv")             -- Prev search with centering

-- Yank to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Other settings
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.ignorecase = true         -- Ignore case in search
vim.opt.smartcase = true          -- Override ignorecase if uppercase

-- Apply Nightfox colorscheme (default variant: nightfox; change to "dayfox", "nordfox", etc. if desired)
vim.cmd.colorscheme "nightfox"

-- End of init.lua
