-- Basic Functions --

function resource.AddDir(dir)
	local f, d = file.Find(dir .. '/*', 'GAME')
	
	for k, v in pairs(f) do
		resource.AddSingleFile(dir .. '/' .. v)
	end
	
	for k, v in pairs(d) do
		resource.AddDir(dir .. '/' .. v)
	end
end

-- General --

resource.AddDir("materials/models/weapons/v_models/hands")
--resource.AddDir("models/weapons")
--resource.AddDir("sound/weapons")
--resource.AddDir("materials/models/weapons")
resource.AddDir("materials/models/wystan")

-- ACR --

resource.AddDir("models/weapons/acr")
resource.AddDir("materials/models/weapons/v_models/masada")
resource.AddDir("materials/models/weapons/w_models/masada")
resource.AddDir("sound/weapons/masadamagpul")

-- FN FAL --

resource.AddDir("models/weapons/fn_fal")
resource.AddDir("materials/models/weapons/v_models/fn_fal_pete")
resource.AddDir("materials/models/weapons/w_models/fn_fal_pete")
resource.AddDir("sound/weapons/fn_fal")

-- HK G3A3 --

resource.AddDir("models/weapons/hkg3a3")
resource.AddDir("materials/models/weapons/v_models/ezjamin_tehsnake_g3")
resource.AddDir("materials/models/weapons/w_models/ezjamin_tehsnake_g3")
resource.AddDir("sound/weapons/hk_g3")

-- JIHAD --

resource.AddDir("materials/models/weapons/v_models/pr0d.c4")
resource.AddDir("materials/models/weapons/w_models/pr0d.c4")

-- RIOT --

resource.AddDir("materials/arleitiss")
resource.AddDir("models/arleitiss")

-- SCAR --

resource.AddDir("models/weapons/scar")
resource.AddDir("materials/models/weapons/v_models/fnscarh")
resource.AddDir("materials/models/weapons/x_models/fnscarh")
resource.AddDir("sound/weapons/fnscarh")

-- Vikhr --

resource.AddDir("models/weapons/vikhr_fix")
resource.AddDir("materials/models/weapons/v_models/vasht sr-3m")
resource.AddDir("materials/models/weapons/x_models/vasht sr-3m")
resource.AddDir("sound/weapons/dmg_vikhr")