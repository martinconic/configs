-- init.lua
-- Final corrected version: Clean structure with the reliable autocmd LSP keymap method.

-- -----------------------------------------------------------------------------
-- 1. BOOTSTRAP LAZY.NVIM (Package Manager)
-- -----------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- -----------------------------------------------------------------------------
-- 2. GLOBAL OPTIONS & KEYMAPS
-- -----------------------------------------------------------------------------
-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editor Options
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.opt.signcolumn = "yes"        -- Always show the sign column
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.termguicolors = true      -- Enable 24-bit RGB colors
vim.opt.mouse = "a"               -- Enable mouse support

-- vim.opt.cursorline = true

-- Customize cursor for different modes (focus on insert mode visibility)
vim.opt.guicursor = {
  'n-v-c-sm:block-Cursor',          -- Normal/visual/command/select: block cursor
  'i-ci-ve:ver50-iCursor',          -- Insert: thin vertical bar (adjust 'ver25' for thickness)
  'r-cr-o:hor20-Cursor',            -- Replace: horizontal bar
  'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor',  -- Blinking settings
}

-- Define highlight groups (set insert cursor to black for light theme contrast)
vim.api.nvim_set_hl(0, 'Cursor', { fg = '#ffffff', bg = '#ff0000' })  -- Red for normal mode (adjust as needed)
vim.api.nvim_set_hl(0, 'iCursor', { bg = '#000000' })  -- Black vertical bar in insert mode

-- Optional: Reset cursor on exit to avoid affecting the terminal
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    vim.opt.guicursor = 'a:ver25'
  end,
})

-- Indentation & Search
vim.opt.tabstop = 4               -- Spaces for a <Tab>
vim.opt.shiftwidth = 4            -- Spaces for autoindent
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.smartindent = true        -- Smart indentation
vim.opt.ignorecase = true         -- Ignore case in search
vim.opt.smartcase = true          -- Smart case in search
vim.opt.incsearch = true          -- Incremental search
vim.opt.hlsearch = false          -- Don't highlight all search results

-- Behavior & UI
vim.opt.wrap = false              -- No line wrap
vim.opt.scrolloff = 8             -- Context lines around cursor
vim.opt.updatetime = 50           -- Faster completion
vim.opt.undofile = true           -- Persist undo history
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Custom Keymaps
local keymap = vim.keymap.set
keymap("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
keymap({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- -----------------------------------------------------------------------------
-- 3. PLUGINS (via lazy.nvim)
-- -----------------------------------------------------------------------------
require("lazy").setup({
  --
  -- THEME & UI
  --  
  -- {
  --   "EdenEast/nightfox.nvim",
  --   lazy = false,
  --   priority = 1000, -- Make sure theme loads first
  --   config = function()
  --     require("nightfox").setup()
  --     vim.cmd.colorscheme "nightfox"
  --   end,
  -- },

-- Add this to your lazy.setup block
{
  "sainnhe/gruvbox-material",
  lazy = false,
  priority = 1000,
  config = function()
    vim.g.gruvbox_material_background = 'hard' -- or 'soft', 'medium'
    vim.cmd.colorscheme "gruvbox-material"
  end,
},

-- Add this to your lazy.setup block
-- {
--   "projekt0n/github-nvim-theme",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     -- The setup function can be minimal or empty now
--     require("github-theme").setup({
--       -- All options are optional
--     })
--
--     -- ‼️ Change the theme name here to select a style
--     vim.cmd("colorscheme github_dark_default")
--   end,
-- },

-- Add this to your lazy.setup block
  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("vscode").setup({
  --       -- You can configure style here, e.g., 'dark' or 'light'
  --       style = 'dark',
  --     })
  --     require("vscode").load()
  --   end,
  -- },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1, -- 0 = filename only, 1 = relative path, 2 = absolute path
            }
          },
        },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("bufferline").setup({}) end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
      require("nvim-tree").setup({ actions = { open_file = { quit_on_open = false } } })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function() require("ibl").setup() end,
  },

  --
  -- CORE FUNCTIONALITY & LANGUAGE SUPPORT
  --
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "rust", "go", "gomod", "toml", "zig" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
  {
    -- ‼️ THIS IS THE CORRECTED LSP SETUP ‼️
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Setup mason and mason-lspconfig
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer", "gopls", "lua_ls", "zls", "clangd" },
        handlers = {
          -- The default handler installs the server and calls setup without any special args.
          -- We will attach keymaps globally using the autocommand below.
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
        },
      })

      -- This global autocommand is the reliable way to attach LSP keymaps for your setup.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          local keymap = vim.keymap.set

          keymap("n", "gd", vim.lsp.buf.definition, opts)
          keymap("n", "gr", vim.lsp.buf.references, opts)
          keymap("n", "gi", vim.lsp.buf.implementation, opts)
          keymap("n", "K", vim.lsp.buf.hover, opts)
          keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
          keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  --
  -- AUTOCOMPLETION
  --
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          
          -- Add Tab/Shift-Tab to jump to the next/previous placeholder
          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" },
          { name = "buffer" }, { name = "path" },
        }),
      })
    end,
  },

  --
  -- "GOOD SEARCH" - Fuzzy Finder
  --
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
        },
      })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols in File" })
      vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Find Symbols in Project" })
      vim.keymap.set("n", "<leader>d", builtin.diagnostics, { desc = "Show Diagnostics" })
    end,
  },

  --
  -- LANGUAGE-SPECIFIC & GIT
  --
  { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup() end },
  {
    "saecki/crates.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("crates").setup() end,
    ft = { "toml" },
  },

  --
  -- OTHER GOODIES
  --
  { "windwp/nvim-autopairs", event = "InsertEnter", config = function() require("nvim-autopairs").setup({}) end },
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },
})
