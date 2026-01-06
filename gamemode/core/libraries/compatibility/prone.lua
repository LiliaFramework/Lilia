--[[
    Folder: Compatibility
    File:  prone.md
]]
--[[
    Prone Mod Compatibility

    Provides compatibility with the Prone Mod addon for prone/crawling mechanics within the Lilia framework.
]]
--[[
    Improvements Done:
        The Prone Mod compatibility module ensures proper handling of prone states during critical player events. It manages the transition out of prone state when players die or load new characters.
        The module operates on the server side to handle player death and character loading events, ensuring players exit prone state to prevent stuck or invalid states.
        It includes automatic prone state cleanup during character transitions and death events to maintain gameplay consistency.
        The module integrates with the Prone Mod's API to provide seamless prone functionality within Lilia's character system.
]]
hook.Add("DoPlayerDeath", "liaProne", function(client) if client:IsProne() then prone.Exit(client) end end)
hook.Add("PlayerLoadedChar", "liaProne", function(client) if client:IsProne() then prone.Exit(client) end end)
