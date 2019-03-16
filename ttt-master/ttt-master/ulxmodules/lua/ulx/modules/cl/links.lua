function ulx.showDonate(name, steamid)
	gui.OpenURL( "http://donate.auroraen.com/index.php?id=" .. steamid .. "&id2=" .. name)
end

function ulx.showForums()
	gui.OpenURL("http://forums.auroraen.com/")
end

function ulx.showRules()
	gui.OpenURL("http://auroraen.com/tttrules")
end