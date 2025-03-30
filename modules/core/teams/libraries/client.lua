function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    local character = client:getChar()
    local class = character:getClass()
    if not character:getClass() then return end
    local classTable = lia.class.list[class]
    hook.Run("AddTextField", L("generalInfo"), "faction", L("faction"), function() return team.GetName(LocalPlayer():Team()) end)
    if classTable.name then hook.Run("AddTextField", L("generalInfo"), "class", L("class"), function() return classTable.name end) end
end