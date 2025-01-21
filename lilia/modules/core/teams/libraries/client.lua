function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    hook.Run("AddTextField", "General Info", "faction", "Faction", function() return team.GetName(LocalPlayer():Team()) end)
    if class then hook.Run("AddTextField", "General Info", "class", "Class", function() return class.name end) end
end
