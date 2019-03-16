hook.Add('Initialize','CH_S_e51e079f0466b1b0c65ef3d621a727ff', function()
	http.Post('http://coderhire.com/api/script-statistics/usage/9829/753/e51e079f0466b1b0c65ef3d621a727ff', {
		port = GetConVarString('hostport'),
		hostname = GetHostName()
	})
end)