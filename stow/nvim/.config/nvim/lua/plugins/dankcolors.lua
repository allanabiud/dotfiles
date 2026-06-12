return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#100F0F',
				base01 = '#100F0F',
				base02 = '#707a79',
				base03 = '#707a79',
				base04 = '#a3b1b0',
				base05 = '#edf5f4',
				base06 = '#edf5f4',
				base07 = '#edf5f4',
				base08 = '#e49b73',
				base09 = '#e49b73',
				base0A = '#52b9b0',
				base0B = '#6dca74',
				base0C = '#a6ece6',
				base0D = '#52b9b0',
				base0E = '#76dbd2',
				base0F = '#76dbd2',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#707a79',
				fg = '#edf5f4',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#52b9b0',
				fg = '#100F0F',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#707a79' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#a6ece6', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#76dbd2',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#52b9b0',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#52b9b0',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#a6ece6',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#6dca74',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#a3b1b0' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#a3b1b0' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#707a79',
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
