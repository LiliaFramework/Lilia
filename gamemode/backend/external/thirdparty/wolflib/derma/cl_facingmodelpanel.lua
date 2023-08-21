--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:SetFOV(15)
end
--------------------------------------------------------------------------------------------------------
function PANEL:SetWT(wt)
    self:SetSize(wt, wt)
end
--------------------------------------------------------------------------------------------------------
function PANEL:LayoutEntity(ent)
    if not ent then return end
    local head = ent:LookupBone("ValveBiped.Bip01_Head1")

    if head > 0 then
        local headpos = ent:GetBonePosition(head)
        self:SetLookAt(headpos)
    end

    ent:SetAngles(Angle(0, 45, 0))
end
--------------------------------------------------------------------------------------------------------
vgui.Register("FacingModelPanel", PANEL, "DModelPanel")
--------------------------------------------------------------------------------------------------------