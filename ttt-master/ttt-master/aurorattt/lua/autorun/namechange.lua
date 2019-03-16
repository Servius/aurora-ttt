hook.Add( "PostGamemodeLoaded", "NameChange Prevention", function()
	local ply = FindMetaTable("Player")
	local oldnick = ply.Nick
	function ply:Nick()
	     if self.origname == nil && oldnick(self) != "unconnected" && oldnick(self) != "" then self.origname = oldnick(self) end
	     return (self:SteamID() == "STEAM_0:0:7193") and "Divine ᴭᴺ" or self.origname or oldnick(self)
	end

	ply.GetName = ply.Nick
	ply.Name = ply.Nick
end)
