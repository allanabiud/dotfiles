return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#131314',
				base01 = '#131314',
				base02 = '#7e7e88',
				base03 = '#7e7e88',
				base04 = '#cfcfdc',
				base05 = '#f8f8ff',
				base06 = '#f8f8ff',
				base07 = '#f8f8ff',
				base08 = '#ff9fb6',
				base09 = '#ff9fb6',
				base0A = '#dadae7',
				base0B = '#a3fbb3',
				base0C = '#f7f7ff',
				base0D = '#dadae7',
				base0E = '#f3f3ff',
				base0F = '#f3f3ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#7e7e88',
				fg = '#f8f8ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#dadae7',
				fg = '#131314',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#7e7e88' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#f7f7ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#f3f3ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#dadae7',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#dadae7',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#f7f7ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a3fbb3',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#cfcfdc' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#cfcfdc' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#7e7e88',
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
