function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    hook.Run("AddTextField", L("generalInfo"), "faction", L("faction"), function() return team.GetName(LocalPlayer():Team()) end)
    if class then hook.Run("AddTextField", L("generalInfo"), "class", L("class"), function() return class.name end) end
end
