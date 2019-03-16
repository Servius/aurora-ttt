local folder = "alib/shared"
local files = file.Find(folder .. "/" .. "*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder .. "/" .. file)
end

folder = "alib/client"
files = file.Find(folder .. "/" .. "*.lua", "LUA")
for _, file in ipairs(files) do
	include(folder .. "/" .. file)
end