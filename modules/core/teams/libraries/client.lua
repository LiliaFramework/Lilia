function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    local character = client:getChar()
    hook.Run("AddTextField", "General Info", "faction", "Faction", function() return team.GetName(LocalPlayer():Team()) end)
    if character:getClass() and lia.class.list[character:getClass()] and lia.class.list[character:getClass()].name then hook.Run("AddTextField", "General Info", "class", "Class", function() return lia.class.list[character:getClass()].name end) end
end

function MODULE:LoadMainMenuInformation(info)
    local client = LocalPlayer()
    local character = client:getChar()
    table.insert(info, "Faction: " .. (team.GetName(client:Team()) or ""))
    if character:getClass() and lia.class.list[character:getClass()] and lia.class.list[character:getClass()].name then table.insert(info, "Class: " .. lia.class.list[character:getClass()].name) end
end