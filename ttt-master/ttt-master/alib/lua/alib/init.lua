if not alib_initialized then
	alib_initialized = true

	AddCSLuaFile("alib/cl_init.lua")
	AddCSLuaFile("autorun/alib_includes.lua")

	local folder = "alib/shared"
	local files = file.Find(folder .. "/" .. "*.lua", "LUA")
	for _, file in ipairs(files) do
		AddCSLuaFile(folder .. "/" .. file)
		include(folder .. "/" .. file)
	end

	folder = "alib/client"
	files = file.Find(folder .. "/" .. "*.lua", "LUA")
	for _, file in ipairs(files) do
		AddCSLuaFile(folder .. "/" .. file)
	end

	folder = "alib/server"
	files = file.Find(folder .. "/" .. "*.lua", "LUA")
	for _, file in ipairs(files) do
		include(folder .. "/" .. file)
	end
end