-- init.lua
-- Final corrected version: Clean structure with the reliable autocmd LSP keymap method.

-- -----------------------------------------------------------------------------
-- 1. BOOTSTRAP LAZY.NVIM (Package Manager)
-- -----------------------------------------------------------------------------
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

-- Custom cursor highlight adjustments (avoid hardcoding solid white background for light themes)
-- vim.api.nvim_set_hl(0, 'Cursor', { fg = '#ffffff', bg = '#ffffff' })
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
vim.opt.mousescroll = "ver:1,hor:1"

-- Custom Keymaps
local keymap = vim.keymap.set
keymap("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
keymap({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
keymap("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Open Neogit" })
keymap("n", "<leader>tb", function()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  print("Background: " .. vim.o.background)
end, { desc = "Toggle Light/Dark Background" })

-- -----------------------------------------------------------------------------
-- 3. PLUGINS (via lazy.nvim)
-- -----------------------------------------------------------------------------
require("lazy").setup({
  --
--THEME & UI
   
  -- =================================----------------==========================
  -- THEMES (Uncomment ANY SINGLE BLOCK below to activate and test it)
  -- Note: For light mode, make sure `vim.o.background = "light"` is set in config!
  -- =================================--------------------------------==========

  -- ---------------------------------------------------------------------------
  -- GRUVBOX VARIANTS
  -- ---------------------------------------------------------------------------

  -- 1. Modern Gruvbox Lua (ellisonleao/gruvbox.nvim) — RECOMMENDED
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("gruvbox").setup({ contrast = "medium" })
  --     vim.o.background = "light" -- Change to "dark" for dark mode
  --     vim.cmd.colorscheme("gruvbox")
  --   end,
  -- },

  -- 2. Gruvbox Material (sainnhe/gruvbox-material)
  -- {
  --   "sainnhe/gruvbox-material",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.gruvbox_material_background = 'hard' -- 'hard', 'medium', 'soft'
  --     vim.o.background = "light" -- Change to "dark" for dark mode
  --     vim.cmd.colorscheme("gruvbox-material")
  --   end,
  -- },

  -- 3. Classic Gruvbox (morhetz/gruvbox)
  -- {
  --   "morhetz/gruvbox",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.gruvbox_contrast_light = 'medium' -- 'hard', 'medium', 'soft'
  --     vim.o.background = "light" -- Change to "dark" for dark mode
  --     vim.cmd.colorscheme("gruvbox")
  --   end,
  -- },

  -- ---------------------------------------------------------------------------
  -- SOLARIZED VARIANTS
  -- ---------------------------------------------------------------------------

  -- 4. Modern Solarized Lua (maxmx03/solarized.nvim) — ACTIVE
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "light" -- Set "light" or "dark"

      require("solarized").setup({
        on_colors = function(colors)
          -- Replace pinkish/magenta colors with calm Solarized blue & cyan
          colors.magenta = colors.blue -- Replaces pink/magenta (#d33682) with Blue (#268bd2)
          colors.violet = colors.cyan  -- Replaces violet (#6c71c4) with Cyan (#2aa198)
          return {
            magenta = colors.blue,
            violet = colors.cyan,
          }
        end,
      })

      vim.cmd.colorscheme("solarized")
    end,
  },

  -- 5. Solarized Osaka (craftzdog/solarized-osaka.nvim)
  -- {
  --   "craftzdog/solarized-osaka.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.o.background = "light" -- Change to "dark" for dark mode
  --     require("solarized-osaka").setup({})
  --     vim.cmd.colorscheme("solarized-osaka")
  --   end,
  -- },

  -- 6. Solarized 8 (lifepillar/vim-solarized8)
  -- {
  --   "lifepillar/vim-solarized8",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.o.background = "light" -- Change to "dark" for dark mode
  --     vim.cmd.colorscheme("solarized8")
  --   end,
  -- },

  -- 7. Solarized Lua (shaunsingh/solarized.nvim)
  -- {
  --   "shaunsingh/solarized.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.o.background = "light" -- Change to "dark" for dark mode
  --     vim.cmd.colorscheme("solarized")
  --   end,
  -- },

  -- ---------------------------------------------------------------------------
  -- OTHER THEMES
  -- ---------------------------------------------------------------------------

  -- 8. macOS Classic (martinconic/macos-classic.nvim)
  -- {
  --   "martinconic/macos-classic.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("macos-classic-light")
  --   end,
  -- },

  -- 9. Nightfox / Dayfox (EdenEast/nightfox.nvim)
  -- {
  --   "EdenEast/nightfox.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("nightfox").setup()
  --     vim.cmd.colorscheme("dayfox") -- Light: "dayfox", "dawnfox" | Dark: "nightfox", "nordfox"
  --   end,
  -- },

  -- 10. GitHub Light / Dark (projekt0n/github-nvim-theme)
  -- {
  --   "projekt0n/github-nvim-theme",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("github-theme").setup({})
  --     vim.cmd("colorscheme github_light_default")
  --   end,
  -- },

  -- 11. VS Code Theme (Mofiqul/vscode.nvim)
  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("vscode").setup({ style = 'light' })
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
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "rust", "go", "gomod", "toml", "zig", "odin" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      -- mason-lspconfig v2 auto-enables installed servers via vim.lsp.enable().
      -- For per-server config, use vim.lsp.config("server_name", { ... }).
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer", "gopls", "lua_ls", "zls", "clangd", "ols" },
      })

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
      vim.keymap.set("n", "<leader>fS", builtin.lsp_dynamic_workspace_symbols, { desc = "Find Symbols in Project" })
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
      vim.keymap.set("n", "<leader>d", builtin.diagnostics, { desc = "Show Diagnostics" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search Git Commits" })
      vim.keymap.set("n", "<leader>gB", builtin.git_branches, { desc = "Search Git Branches" })
    end,
  },

  --
  -- LANGUAGE-SPECIFIC & GIT
  --
{
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      -- This on_attach function runs whenever gitsigns is active on a file
      on_attach = function(bufnr)
        -- Get the gitsigns API
        local gs = package.loaded.gitsigns

        -- Helper function to set a keymap only for the current buffer
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Your requested keymap for blaming a line
        -- NOTE: I've used <leader>gB (capital B) to avoid the conflict with your
        -- Telescope shortcut for Git branches (<leader>gb) that we discussed.
        map("n", "<leader>gb", gs.blame_line, { desc = "Blame Line" })
      end,
    })
  end,
},

    -- Add this with your other plugins, for example, after gitsigns
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim",        -- optional
    },
    config = true
  },



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

-- require("borland_blue").setup()

-- -----------------------------------------------------------------------------
-- ANTIGRAVITY / VS CODE INTEGRATION
-- -----------------------------------------------------------------------------
if vim.g.vscode then
  local vscode = require("vscode")
  local keymap = vim.keymap.set

  vim.g.mapleader = " "

  -- File Explorer & Buffer controls
  keymap("n", "<leader>e", function() vscode.action("workbench.action.toggleSidebarVisibility") end, { desc = "Toggle Explorer" })
  keymap("n", "<leader>q", function() vscode.action("workbench.action.closeActiveEditor") end, { desc = "Close Buffer" })

  -- Telescope equivalents
  keymap("n", "<leader>ff", function() vscode.action("workbench.action.quickOpen") end, { desc = "Find Files" })
  keymap("n", "<leader>fg", function() vscode.action("workbench.action.findInFiles") end, { desc = "Live Grep" })
  keymap("n", "<leader>fb", function() vscode.action("workbench.action.showAllEditors") end, { desc = "Find Buffers" })
  keymap("n", "<leader>fs", function() vscode.action("workbench.action.gotoSymbol") end, { desc = "Document Symbols" })
  keymap("n", "<leader>fS", function() vscode.action("workbench.action.showAllSymbols") end, { desc = "Workspace Symbols" })
  keymap("n", "<leader>d",  function() vscode.action("workbench.action.showErrorsWarnings") end, { desc = "Show Diagnostics" })

  -- LSP Keymaps
  keymap("n", "gd", function() vscode.action("editor.action.revealDefinition") end)
  keymap("n", "gr", function() vscode.action("editor.action.goToReferences") end)
  keymap("n", "gi", function() vscode.action("editor.action.goToImplementation") end)
  keymap("n", "K",  function() vscode.action("editor.action.showHover") end)
  keymap("n", "<leader>rn", function() vscode.action("editor.action.rename") end)
  keymap({"n", "v"}, "<leader>ca", function() vscode.action("editor.action.quickFix") end)

  -- Git Keymaps
  keymap("n", "<leader>gg", function() vscode.action("workbench.view.scm") end)
end
