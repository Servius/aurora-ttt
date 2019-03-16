hook.Add('Initialize','CH_S_775482382e454660f34475e61fd1ceae', function()
	http.Post('http://coderhire.com/api/script-statistics/usage/9829/805/775482382e454660f34475e61fd1ceae', {
		port = GetConVarString('hostport'),
		hostname = GetHostName()
	})
end)