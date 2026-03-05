return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#121318',
				base01 = '#121318',
				base02 = '#999ba5',
				base03 = '#999ba5',
				base04 = '#eff2ff',
				base05 = '#f8f9ff',
				base06 = '#f8f9ff',
				base07 = '#f8f9ff',
				base08 = '#ff9fb8',
				base09 = '#ff9fb8',
				base0A = '#c0ccff',
				base0B = '#a5ffb4',
				base0C = '#dee4ff',
				base0D = '#c0ccff',
				base0E = '#cbd5ff',
				base0F = '#cbd5ff',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#999ba5',
				fg = '#f8f9ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#c0ccff',
				fg = '#121318',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#999ba5' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#dee4ff', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#cbd5ff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#c0ccff',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#c0ccff',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#dee4ff',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a5ffb4',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#eff2ff' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#eff2ff' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#999ba5',
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
