﻿hook.Add("DoPlayerDeath", "liaProne", function(client) if client:IsProne() then prone.Exit(client) end end)
hook.Add("PlayerLoadedChar", "liaProne", function(client) if client:IsProne() then prone.Exit(client) end end)
