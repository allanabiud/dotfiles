---@diagnostic disable: undefined-field, undefined-global --temp while fields are incomplete within types.yazi
---@diagnostic disable: redefined-local --reusing err
local M = {}

function M:peek(job)
	local ok, err = self:preload(job)
	if not ok or err then
		--ya.dbg("Peek failed during preload", tostring(err))
		return
	end

	local cache = ya.file_cache(job)
	if not cache then
		return
	end

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end
	local step = math.max(0, cx.active.preview.skip + ya.clamp(-1, job.units, 1))

	local metadata_url = ya.file_cache({ file = job.file, skip = 999999 })
	if not metadata_url then
		return
	end
	local filenames = {}

	local metadata = io.open(tostring(metadata_url))
	if metadata then
		for filename in metadata:lines() do
			table.insert(filenames, filename)
		end
		metadata:close()

		step = math.min(step, #filenames - 1)
	end

	--ya.dbg("Seek:", tostring(step), "Max:", #filenames - 1, tostring(job.file.url))
	ya.emit("peek", { step, only_if = job.file.url })
end

function M:preload(job)
	local metadata_url = ya.file_cache({ file = job.file, skip = 999999 })
	if not metadata_url then
		return false, Err("Failed to get metadata URL")
	end
	local filenames = {}

	local meta_cha, _ = fs.cha(metadata_url)
	if not meta_cha or meta_cha.len == 0 then
		local filenames, output = self.generate_list(job.file.url)
		if not filenames then
			return false, Err("Failed to generate archive list", output)
		end

		local write_output, err = fs.write(metadata_url, table.concat(filenames, "\n"))
		if not write_output then
			return false, Err("Failed to write metadata cache", err)
		end
	else
		local metadata = io.open(tostring(metadata_url))
		if metadata then
			for filename in metadata:lines() do
				table.insert(filenames, filename)
			end
			metadata:close()
		end
	end

	job.skip = job.skip >= #filenames and (#filenames - 1) or job.skip
	--ya.dbg("Load:", job.skip + 1, "Max:", #filenames, "Filenames:", filenames)

	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local extract_output, err = Command("7z")
		:arg({ "-so", "e", tostring(job.file.url), filenames[job.skip + 1] })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()
	if not extract_output then
		return false, Err("Failed to start 7z to extract image: %s", err)
	end

	local write_output, err = fs.write(cache, extract_output.stdout)
	if not write_output then
		return false, Err("Failed to write cache", err)
	end

	-- Unsure whether to simply return full resolution or allow image_precache() to deal with it
	-- Both work fine, the overhead of calling extra function is not noticeable
	return ya.image_precache(cache, cache)
end

function M.generate_list(url)
	local list_child, err = Command("7z")
		:arg({ "-ba", "l", tostring(url) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()
	if not list_child then
		return false, Err("Failed to spawn 7z", err)
	end

	local list_stdout = list_child:take_stdout()
	if not list_stdout then
		return false, Err("Failed to list archive with 7z")
	end

	local awk_child, err = Command("awk")
		:arg({ [[length($0) > 53 && tolower(substr($0, 54)) ~ /\.(jpg|jpeg|png|gif)$/ { print substr($0, 54) }]] })
		:stdin(list_stdout)
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()
	if not awk_child then
		return false, Err("Failed to spawn awk", err)
	end

	local awk_output, err = awk_child:wait_with_output()
	if not awk_output then
		return false, Err("Can't read awk output", err)
	end

	local filenames = {}
	for filename in awk_output.stdout:gmatch("[^\n]+") do
		table.insert(filenames, filename)
	end
	table.sort(filenames)
	return filenames
end

return M
