-- lua/borland_blue.lua
-- Simple Borland Blue theme for Neovim

local M = {}

function M.setup()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.g.colors_name = "borland_blue"

  local set_hl = vim.api.nvim_set_hl

  -- Base colors
  local bg = "#0000A0"  -- Classic Borland blue background
  local fg = "#FFFF00"  -- Bright yellow text
  local comment = "#00FFFF"  -- Cyan comments
  local keyword = "#FFFFFF"  -- White keywords
  local string = "#00FF00"   -- Green strings
  local number = "#FF00FF"   -- Magenta numbers
  local typec = "#FFD700"    -- Golden types

  -- Editor
  set_hl(0, "Normal", { fg = fg, bg = bg })
  set_hl(0, "LineNr", { fg = "#FFFFFF", bg = bg })
  set_hl(0, "CursorLineNr", { fg = "#FFFFFF", bg = "#0000AA", bold = true })
  set_hl(0, "CursorLine", { bg = "#000080" })
  set_hl(0, "SignColumn", { bg = bg })
  set_hl(0, "StatusLine", { fg = fg, bg = "#000090", bold = true })
  set_hl(0, "StatusLineNC", { fg = "#808080", bg = "#000060" })
  set_hl(0, "Visual", { bg = "#000060" })
  set_hl(0, "VertSplit", { fg = "#000060", bg = "#000060" })

  -- Syntax
  set_hl(0, "Comment", { fg = comment, italic = true })
  set_hl(0, "Keyword", { fg = keyword, bold = true })
  set_hl(0, "Identifier", { fg = fg })
  set_hl(0, "String", { fg = string })
  set_hl(0, "Number", { fg = number })
  set_hl(0, "Type", { fg = typec, bold = true })
  set_hl(0, "Function", { fg = "#FFFFFF", bold = true })
  set_hl(0, "Constant", { fg = "#FF8080" })
  set_hl(0, "Operator", { fg = "#FFFFFF" })
  set_hl(0, "PreProc", { fg = "#FFA500" })
  set_hl(0, "Special", { fg = "#00FFFF" })

  -- Telescope and Lualine compatibility
  set_hl(0, "TelescopeNormal", { bg = bg, fg = fg })
  set_hl(0, "TelescopeBorder", { fg = "#FFFFFF", bg = bg })
  set_hl(0, "TelescopePromptNormal", { bg = "#000090" })

  set_hl(0, "lualine_c_normal", { fg = fg, bg = "#000090" })
end

return M

