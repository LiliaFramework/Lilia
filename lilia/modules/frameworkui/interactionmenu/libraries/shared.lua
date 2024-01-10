PIM.options = PIM.options or {}
function PIM:AddOption(name, data)
    self.options[name] = data
end

function PIM:CheckPossibilities()
    for _, v in pairs(self.options) do
        if not LocalPlayer():GetEyeTrace().Entity:IsPlayer() then return end
        if v.shouldShow(LocalPlayer(), LocalPlayer():GetEyeTrace().Entity) then return true end
    end
    return false
end

function PIM:InitializedModules()
    hook.Run("AddPIMOption", self.options)
end

function PIM:CheckDistance(client, ent)
    return ent:GetPos():DistToSqr(client:GetPos()) < self.MaxInteractionDistance
end
