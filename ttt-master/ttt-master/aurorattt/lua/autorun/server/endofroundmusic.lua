-- You can add up to 3 sounds for this. Add or delete resource.addfile as you need
resource.AddFile("sound/endroundmusic/ending_innocent_amped.mp3")
resource.AddFile("sound/endroundmusic/ending_traitor_amped.mp3")

-- Remember to change the name of the sounds to the sound you want from above
local function PlayMusic(wintype)
   if wintype == WIN_INNOCENT then
      BroadcastLua('surface.PlaySound("endroundmusic/ending_innocent_amped.mp3")')

   else
      BroadcastLua('surface.PlaySound("endroundmusic/ending_traitor_amped.mp3")')
   end
end
hook.Add("TTTEndRound", "MyMusic", PlayMusic)
