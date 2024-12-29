-- Border
require("full-border"):setup()

-- Directory preview
require("eza-preview"):setup({
	-- Determines the directory depth level to tree preview (default: 3)
	level = 2,
	-- Whether to follow symlinks when previewing directories (default: false)
	follow_symlinks = true,
	-- Whether to show target file info instead of symlink info (default: false)
	dereference = false,
})

-- Statusline and tabline
require("yatline"):setup({
	--theme = my_theme,
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },

	style_a = {
		fg = "black",
		bg_mode = {
			normal = "white",
			select = "brightyellow",
			un_set = "brightred",
		},
	},
	style_b = { bg = "brightblack", fg = "brightwhite" },
	style_c = { bg = "black", fg = "brightwhite" },

	permissions_t_fg = "green",
	permissions_r_fg = "yellow",
	permissions_w_fg = "red",
	permissions_x_fg = "cyan",
	permissions_s_fg = "white",

	tab_width = 20,
	tab_use_inverse = false,

	selected = { icon = "󰻭", fg = "yellow" },
	copied = { icon = "", fg = "green" },
	cut = { icon = "", fg = "red" },

	total = { icon = "󰮍", fg = "yellow" },
	succ = { icon = "", fg = "green" },
	fail = { icon = "", fg = "red" },
	found = { icon = "󰮕", fg = "blue" },
	processed = { icon = "󰐍", fg = "green" },

	show_background = true,

	display_header_line = true,
	display_status_line = true,

	component_positions = { "header", "tab", "status" },

	header_line = {
		left = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "left" } },
			},
			section_b = {},
			section_c = {
				{ type = "coloreds", custom = false, name = "symlink" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "date", params = { "%A, %d %B %Y" } },
			},
			section_b = {
				{ type = "string", custom = false, name = "date", params = { "%X" } },
			},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_path" },
				{ type = "coloreds", custom = false, name = "count" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "cursor_position" },
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", custom = false, name = "permissions" },
				{ type = "coloreds", custom = false, name = "githead" },
			},
		},
	},
})
-- Symlink in tabline
require("yatline-symlink"):setup()
-- Githead in tabline
require("yatline-githead"):setup()

-- Git
require("git"):setup()

-- Bunny
local home = os.getenv("HOME")
require("bunny"):setup({
	hops = {
		{ tag = "Home", path = home, key = "h" },
		{ tag = "config", path = home .. "/.config", key = "c" },
		{ tag = "Desktop", path = home .. "/Desktop", key = "D" },
		{ tag = "Documents", path = home .. "/Documents", key = "o" },
		{ tag = "Downloads", path = home .. "/Downloads", key = "d" },
		{ tag = "Music", path = home .. "/Music", key = "m" },
		{ tag = "Pictures", path = home .. "/Pictures", key = "p" },
		{ tag = "Videos", path = home .. "/Videos", key = "v" },
		{ tag = "NYAGAKA-PC", path = home .. "/Desktop/SMB/NYAGAKA-PC", key = "S" },
	},
	notify = true, -- notify after hopping, default is false
	fuzzy_cmd = "fzf", -- fuzzy searching command, default is fzf
})

-- Fuse Archive
require("fuse-archive"):setup({
	smart_enter = true,
})
