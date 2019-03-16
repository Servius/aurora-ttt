hook.Add("InitPostEntity","PointShop_Networking",function () 
	if Pointshop2 then
		local plyMeta = FindMetaTable( "Player" )
		function plyMeta:PS2_GetPoints()
			self.LastRefresh = self.LastRefresh or 0
			if (CurTime() - self.LastRefresh) > 5 then
				self.Points = self:GetNWInt("Points", 0)
				self.LastRefresh = CurTime()
			end
			return self.Points or 0
		end

		if SERVER then
			timer.Create("PS2_Update", 5, 0, function()
				for k,v in pairs(player.GetAll()) do
					local wallet = v.PS2_Wallet
					if wallet then
						v:SetNWInt("Points", wallet.points)
					else
						v:SetNWInt("Points", 0)
					end
				end
			end)
		end
	end
end)
