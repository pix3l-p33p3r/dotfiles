--- @since 26.8.15
-- Hover-to-play GIF in the preview pane.
-- Yazi's image previewer is one still frame. This plugin extracts frames once,
-- then advances them with ya.image_show. Peek runs in an isolated Lua VM: no `cx`.

local M = {}

local function fail(job, s)
	ya.preview_widget(job, ui.Text.parse(tostring(s)):area(job.area):wrap(ui.Wrap.YES))
end

local function dir_of(job)
	local cache = ya.file_cache({ file = job.file, skip = 0 })
	if not cache then
		return nil
	end
	return tostring(cache) .. ".frames"
end

local function count_frames(dir)
	local n = 0
	while fs.cha(Url(string.format("%s/f-%04d.png", dir, n))) do
		n = n + 1
		if n > 240 then
			break
		end
	end
	return n
end

local function read_delay(dir)
	local f = io.open(dir .. "/delay", "r")
	if not f then
		return 0.1
	end
	local n = tonumber(f:read("*a"))
	f:close()
	if not n or n < 0.03 then
		return 0.1
	end
	return n
end

function M:preload(job)
	local dir = dir_of(job)
	if not dir then
		return false, "gif-preview: no cache path"
	end
	if count_frames(dir) > 0 then
		return true
	end

	local mk, mkerr = Command("mkdir"):arg({ "-p", dir }):output()
	if not mk then
		return false, "mkdir: " .. tostring(mkerr)
	elseif not mk.status.success then
		return false, "mkdir failed"
	end

	local path = tostring(job.file.path)
	local max_w = rt.preview.max_width or 600
	local max_h = rt.preview.max_height or 900
	local out, err = Command("magick")
		:stderr(Command.PIPED)
		:arg({
			path,
			"-coalesce",
			"-resize",
			string.format("%dx%d>", max_w, max_h),
			"+adjoin",
			dir .. "/f-%04d.png",
		})
		:output()

	if not out then
		return false, "magick: " .. tostring(err)
	elseif not out.status.success then
		return false, "magick: " .. (out.stderr or "failed")
	elseif count_frames(dir) < 1 then
		return false, "magick produced no frames"
	end

	local id = Command("magick"):arg({ "identify", "-format", "%T\n", path }):output()
	local cs = 10
	if id and id.stdout then
		cs = tonumber(id.stdout:match("%d+")) or 10
	end
	if cs < 2 then
		cs = 10
	end
	local f = io.open(dir .. "/delay", "w")
	if f then
		f:write(tostring(cs / 100))
		f:close()
	end
	return true
end

function M:peek(job)
	local ok, err = self:preload(job)
	if not ok then
		return fail(job, err)
	end

	local dir = dir_of(job)
	local n = count_frames(dir)
	if n < 1 then
		return fail(job, "gif-preview: empty")
	end

	local i = (tonumber(job.skip) or 0) % n
	local _, show_err = ya.image_show(Url(string.format("%s/f-%04d.png", dir, i)), job.area)
	ya.preview_widget(job, show_err)
	if show_err or n < 2 then
		return
	end

	ya.sleep(read_delay(dir))
	ya.emit("peek", { i + 1, only_if = job.file.url })
end

function M:seek() end

return M
