
local PANEL = {}

function PANEL:Init()
    self:SetFOV(15)
end


function PANEL:SetWT(wt)
    self:SetSize(wt, wt)
end


function PANEL:LayoutEntity(entity)
    if not entity then return end
    local head = entity:LookupBone("ValveBiped.Bip01_Head1")
    if head > 0 then
        local headpos = entity:GetBonePosition(head)
        self:SetLookAt(headpos)
    end

    entity:SetAngles(Angle(0, 45, 0))
end


vgui.Register("FacingModelPanel", PANEL, "DModelPanel")

