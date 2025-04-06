function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    hook.Run("AddTextField", "General Info", "faction", "Faction", function() return team.GetName(client:Team()) end)
    local classID = character:getClass()
    local classData = lia.class.list[classID]
    if classID and classData and classData.name then hook.Run("AddTextField", "General Info", "class", "Class", function() return classData.name end) end
end