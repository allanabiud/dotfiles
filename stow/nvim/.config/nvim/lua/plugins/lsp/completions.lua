return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
    "nvim-tree/nvim-web-devicons",
    "brenoprata10/nvim-highlight-colors",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local function setup_highlights()
      local colors = require("base46").theme_tables["dms"] and require("base46").theme_tables["dms"].base_16
      if not colors then
        return
      end
      vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = colors.base0D, fg = colors.base00, bold = true, italic = true })
      vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = colors.base0D })
      vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = colors.base0D })
    end

    setup_highlights()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = setup_highlights,
    })

    require("blink.cmp").setup({
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept", "fallback" },
        ["<S-b>"] = { "scroll_documentation_up" },
        ["<S-f>"] = { "scroll_documentation_down" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            opts = {
              extended_filetypes = {
                htmldjango = { "html", "loremipsum", "djangohtml" },
                html = { "loremipsum" },
                python = { "django" },
                gdscript = { "gdscript" },
              },
            },
          },
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  if ctx.item.source_name == "LSP" then
                    local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
                    if color_item and color_item.abbr ~= "" then
                      return color_item.abbr
                    end
                    return (require("lspkind").symbol_map[ctx.kind] or ctx.kind_icon) .. ctx.icon_gap
                  elseif ctx.item.source_name == "Path" then
                    local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                    return (dev_icon or ctx.kind_icon) .. ctx.icon_gap
                  end
                  return ctx.kind_icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  local hl = "BlinkCmpKind" .. ctx.kind
                  if ctx.item.source_name == "LSP" then
                    local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
                    if color_item and color_item.abbr_hl_group then
                      hl = color_item.abbr_hl_group
                    end
                  end
                  return hl
                end,
              },
            },
          },
        },
      },
    })
  end,
}
