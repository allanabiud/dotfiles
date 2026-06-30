return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#000000',
				base01 = '#000000',
				base02 = '#8ba39e',
				base03 = '#8ba39e',
				base04 = '#e0fff8',
				base05 = '#f2fffc',
				base06 = '#f2fffc',
				base07 = '#f2fffc',
				base08 = '#ff8142',
				base09 = '#ff8142',
				base0A = '#28ffd0',
				base0B = '#4eff59',
				base0C = '#8dffe6',
				base0D = '#28ffd0',
				base0E = '#4effd8',
				base0F = '#4effd8',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#8ba39e',
				fg = '#f2fffc',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#28ffd0',
				fg = '#000000',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#8ba39e' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#8dffe6', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#4effd8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#28ffd0',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#28ffd0',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#8dffe6',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#4eff59',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#e0fff8' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#e0fff8' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#8ba39e',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
