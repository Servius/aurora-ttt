local EVENT = {}

function EVENT:Prepare()
	self:EventNotification()
end

function EVENT:Begin()
	for _,ply in pairs(player.GetAll()) do
		if ply:Alive() and ply:IsTerror() then
			local boneid = ply:LookupBone("ValveBiped.Bip01_Head1")
			if boneid then
				ply:ManipulateBoneScale(boneid, Vector(3, 3, 3))
			end
		end
	end
end

function EVENT:End()
	for _,ply in pairs(player.GetAll()) do
		local boneid = ply:LookupBone("ValveBiped.Bip01_Head1")
		if boneid then
			ply:ManipulateBoneScale(boneid, Vector(1, 1, 1))
		end
	end
end

wyozitev.RegisterEvent("bighead", EVENT)