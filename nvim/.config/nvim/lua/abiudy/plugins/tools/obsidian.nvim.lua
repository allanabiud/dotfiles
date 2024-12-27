return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre "
  --     .. vim.fn.expand("~")
  --     .. "/Documents/Obsidian/Personal/*.md",
  --   "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Obsidian/Personal/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("obsidian").setup({
      ui = {
        enable = false,
      },
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/Obsidian",
        },
      },
      notes_subdir = "notes",
      -- Where to put new notes. Valid options are
      --  * "current_dir" - put new notes in same directory as the current buffer.
      --  * "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "notes_subdir",
      daily_notes = {
        -- Optional, if you keep daily notes in a separate directory.
        folder = "notes/dailies",
        -- Optional, if you want to change the date format for the ID of daily notes.
        date_format = "%d-%m-%Y",
        -- Optional, if you want to change the date format of the default alias of daily notes.
        alias_format = "%B %-d, %Y",
        -- Optional, default tags to add to each new daily note created.
        default_tags = { "daily-notes" },
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = nil,
      },
      completion = {
        -- Set to false to disable completion.
        nvim_cmp = true,
        -- Trigger completion at 2 chars.
        min_chars = 2,
      },
      -- Either 'wiki' or 'markdown'.
      preferred_link_style = "wiki",
      templates = {
        folder = "templates",
        date_format = "%a, %d-%m-%Y",
        time_format = "%H:%M",
        -- A map for custom variables, the key should be the variable and the value a function
        substitutions = {},
      },
      picker = {
        -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
        name = "telescope.nvim",
        -- Optional, configure key mappings for the picker. These are the defaults.
        -- Not all pickers support all mappings.
        note_mappings = {
          -- Create a new note from your query.
          new = "<C-x>",
          -- Insert a link to the selected note.
          insert_link = "<C-l>",
        },
        tag_mappings = {
          -- Add tag(s) to current note.
          tag_note = "<C-x>",
          -- Insert a tag at the current location.
          insert_tag = "<C-l>",
        },
      },
      -- Optional, determines how certain commands open notes. The valid options are:
      -- 1. "current" (the default) - to always open in the current window
      -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
      -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
      open_notes_in = "current",
      -- Specify how to handle attachments.
      attachments = {
        -- The default folder to place images in via `:ObsidianPasteImg`.
        -- If this is a relative path it will be interpreted as relative to the vault root.
        -- You can always override this per image by passing a full path to the command instead of just a filename.
        img_folder = "assets/imgs", -- This is the default
        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        ---@return string
        img_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("%s-", os.time())
        end,
        -- A function that determines the text to insert in the note when pasting an image.
        -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
        -- This is the default implementation.
        ---@param client obsidian.Client
        ---@param path obsidian.Path the absolute path to the image file
        ---@return string
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      ---@param url string
      follow_url_func = function(url)
        -- Open the URL in the default web browser.
        vim.fn.jobstart({ "xdg-open", url }) -- linux
        -- vim.ui.open(url) -- need Neovim 0.10.0+
      end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
      -- file it will be ignored but you can customize this behavior here.
      ---@param img string
      follow_img_func = function(img)
        vim.fn.jobstart({ "xdg-open", url }) -- linux
      end,

      -- Keymaps
      -- You can use the following keymaps to interact with Obsidian:
      vim.keymap.set("n", "<leader>on", ":ObsidianNew<cr>", { desc = "Create a new note" }),
      vim.keymap.set(
        "n",
        "<leader>oq",
        ":ObsidianQuickSwitch<cr>",
        { desc = "Quickly switch to (or open) another note in your vault" }
      ),
      vim.keymap.set("n", "<leader>ofl", ":ObsidianFollowLink<cr>", { desc = "Follow note reference" }),
      vim.keymap.set(
        "n",
        "<leader>ofv",
        ":ObsidianFollowLink vsplit<cr>",
        { desc = "Follow note reference in a vsplit" }
      ),
      vim.keymap.set(
        "n",
        "<leader>ofh",
        ":ObsidianFollowLink hsplit<cr>",
        { desc = "Follow note reference in a hsplit" }
      ),
      vim.keymap.set("v", "<leader>oll", ":ObsidianLink", { desc = "Link to a note" }),
      vim.keymap.set("v", "<leader>oln", ":ObsidianLinkNew", { desc = "Create a new note and link to it" }),
      vim.keymap.set("n", "<leader>oL", ":ObsidianLinks<cr>", { desc = "List links in the current note" }),
      vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<cr>", { desc = "List backlinks" }),
      vim.keymap.set("n", "<leader>og", ":ObsidianTags<cr>", { desc = "List tags" }),
      vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate<cr>", { desc = "Insert a template" }),
      vim.keymap.set("n", "<leader>oT", ":ObsidianNewFromTemplate<cr>", { desc = "Create a new note from a template" }),
      vim.keymap.set("n", "<leader>oc", ":ObsidianToggleCheckbox<cr>", { desc = "Cycle throught checkbox options" }),
      vim.keymap.set("n", "<leader>os", ":ObsidianSearch<cr>", { desc = "Search for (or create) notes" }),
      vim.keymap.set("n", "<leader>odl", ":ObsidianDailies<cr>", { desc = "List daily notes" }),
      vim.keymap.set("n", "<leader>or", ":ObsidianRename<cr>", { desc = "Rename current note" }),
      vim.keymap.set("n", "<leader>odt", ":ObsidianToday<cr>", { desc = "Create a new daily note" }),
      vim.keymap.set("n", "<leader>ody", ":ObsidianYesterday<cr>", { desc = "Create a new daily note for yesterday" }),
      vim.keymap.set("n", "<leader>odm", ":ObsidianTomorrow<cr>", { desc = "Create a new daily note for tomorrow" }),
      vim.keymap.set(
        "n",
        "<leader>oc",
        ":ObsidianTOC<cr>",
        { desc = "Load the table of contents of the current note" }
      ),
      vim.keymap.set("n", "<leader>om", ":MarkdownPreview<cr>", { desc = "Preview markdown" }),
    })
  end,
}
