--[[
    Compatibility helpers for the Prone Mod.
    Automatically exits the prone state when a player dies or
    loads a new character so players don't get stuck.
]]
hook.Add("DoPlayerDeath", "liaProne", function(client) if client:IsProne() then prone.Exit(client) end end)
hook.Add("PlayerLoadedChar", "liaProne", function(client) if client:IsProne() then prone.Exit(client) end end)
