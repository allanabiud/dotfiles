return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "lua", "markdown", "html", "htmldjango", "css", "bash", "javascript" },
      auto_install = true,
      highlight = {
        enable = true,
        -- disable = { "html" },
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      autotag = { enable = true },
    })
    -- Configure filetype detection
    vim.filetype.add({
      extension = {
        html = "html",
        htmldjango = "htmldjango",
        djhtml = "htmldjango",
        django = "htmldjango",
        jinja = "htmldjango",
      },
    })

    -- Set up better JavaScript recognition in HTML/Django
    vim.g.javascript_plugin_jsdoc = 1
    vim.g.javascript_plugin_ngdoc = 1

    -- Configure HTML and Django syntax settings
    local function setup_html_syntax()
      vim.cmd([[
    let g:html_indent_script1 = "inc"
    let g:html_indent_style1 = "inc"
    let g:html_indent_inctags = "html,body,head,tbody,div,script"
  ]])
    end

    -- Create an autocommand group for HTML and HTMLDjango files
    vim.api.nvim_create_augroup("HTMLSettings", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = "HTMLSettings",
      pattern = { "html", "htmldjango" },
      callback = setup_html_syntax,
    })

    -- Configure Django template syntax
    vim.cmd([[
  let g:django_template_tags = 1
  let g:django_template_blocks = 1
]])

    -- Set up improved JavaScript syntax highlighting in HTML/Django
    vim.cmd([[
  " Enable syntax highlighting within Django template tags
  let g:htmldjango_enable_javascript = 1
  
  " Configure indentation
  let g:html_indent_autotags = 'html,body,head,tbody,script'
  let g:html_indent_script1 = "auto"
  let g:html_indent_style1 = "auto"
  
  " Enable syntax highlighting in both HTML and Django template blocks
  autocmd FileType htmldjango,html syntax cluster djangoBlocks add=javascriptBlock,javascriptExpression
]])

    -- Optional: Add specific settings for Django template tags containing JavaScript
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "htmldjango",
      callback = function()
        vim.cmd([[
      " Improve syntax highlighting inside Django template tags
      syn region djangoStatement contained start="{%" end="%}"
      syn region djangoVariable contained start="{{" end="}}"
      syn region djangoComment contained start="{#" end="#}"
      
      " Enable JavaScript highlighting within Django template tags
      syn region djangoJavaScript contained start="<script>" end="</script>"
        \ contains=@htmlJavaScript,djangoStatement,djangoVariable,djangoComment
        \ keepend
      
      " Add JavaScript syntax to Django template tags
      syn cluster djangoBlocks add=djangoJavaScript
    ]])
      end,
    })
  end,
}
