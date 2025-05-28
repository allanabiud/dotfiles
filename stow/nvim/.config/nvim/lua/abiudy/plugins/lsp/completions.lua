return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    "hrsh7th/cmp-nvim-lsp",
    {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Include snippets not in global snippets for friendly-snippets
    luasnip.filetype_extend("htmldjango", { "html", "loremipsum", "djangohtml" })
    luasnip.filetype_extend("html", { "loremipsum" })
    luasnip.filetype_extend("python", { "django" })
    luasnip.filetype_extend("ejs", { "html", "ejs" })

    -- Set up custom highlight for PmenuSel (selector in the completion window)
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#005f87", fg = "#ffffff", bold = true, italic = true })

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:CmpBorder,FloatBorder:CmpBorder,CursorLine:PmenuSel",
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpBorder,FloatBorder:CmpBorder",
        },
      },
      view = {
        entries = {
          follow_cursor = true,
        },
      },
      mapping = cmp.mapping.preset.insert({
        -- Previous Suggestion
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<Up>"] = cmp.mapping.select_prev_item(),
        -- Next Suggestion
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<Down>"] = cmp.mapping.select_next_item(),
        -- Scroll Documentation
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- Show completion window
        ["<C-Space>"] = cmp.mapping.complete(),
        -- Close completion window
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        -- Confirm Completion
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = false,
        }),
        -- ["<Tab>"] = cmp.mapping(function(fallback)
        --   if require("luasnip").expand_or_jumpable() then
        --     require("luasnip").expand_or_jump()
        --   else
        --     fallback()
        --   end
        -- end, { "i", "s" }),
        --
        -- ["<S-Tab>"] = cmp.mapping(function(fallback)
        --   if cmp.visible() then
        --     cmp.select_prev_item()
        --   elseif require("luasnip").jumpable(-1) then
        --     require("luasnip").jump(-1)
        --   else
        --     fallback()
        --   end
        -- end, { "i", "s" }),
      }),

      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
        { name = "supermaven" },
        -- { name = 'vim-dadbod-completion' },
      }),

      -- configure lspkind for vs-code like pictograms and colors in completion menu
      formatting = {
        format = function(entry, item)
          -- Step 1: Check if the item is an Emmet suggestion
          if entry.source.name == "nvim_lsp" and entry.completion_item.detail == "Emmet Abbreviation" then
            item.kind = "Emmet Abbreviation" -- Customize the label for Emmet
          end

          -- Step 2: Apply color formatting
          local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
          if color_item.abbr_hl_group then
            item.kind_hl_group = color_item.abbr_hl_group
            item.kind = color_item.abbr
          end

          -- Step 3: Apply lspkind formatting
          item = lspkind.cmp_format({
            mode = "symbol_text",
            symbol_map = { Supermaven = "" },
            maxwidth = 50,
            ellipsis_char = "...",
          })(entry, item)

          -- Optional: Set custom highlights for Emmet or any other items
          vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#6CC644" })

          return item
        end,
      },
    })
  end,
}
