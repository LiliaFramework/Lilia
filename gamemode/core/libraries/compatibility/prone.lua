﻿hook.Add("DoPlayerDeath", "PRONE_DoPlayerDeath", function(client) if client:IsProne() then prone.Exit(client) end end)
hook.Add("PlayerLoadedChar", "PRONE_PlayerLoadedChar", function(client) if client:IsProne() then prone.Exit(client) end end)
