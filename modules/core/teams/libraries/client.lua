function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    local character = client:getChar()
    hook.Run("AddTextField", "General Info", "faction", "Faction", function() return team.GetName(LocalPlayer():Team()) end)
    if character:getClass() and lia.class.list[character:getClass()] and lia.class.list[character:getClass()].name then hook.Run("AddTextField", "General Info", "class", "Class", function() return lia.class.list[character:getClass()].name end) end
end