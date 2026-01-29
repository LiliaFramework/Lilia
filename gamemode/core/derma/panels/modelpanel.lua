local PANEL = {}
function PANEL:Init()
    self.brightness = 1
    self:SetCursor("none")
end

function PANEL:SetModel(model)
    DModelPanel.SetModel(self, model)
    local ent = self.Entity
    if not IsValid(ent) then return end
    local seq = ent:LookupSequence("idle_all_01")
    if seq > 0 then
        ent:ResetSequence(seq)
        return
    end

    seq = ent:SelectWeightedSequence(ACT_IDLE)
    if seq <= 0 then seq = ent:LookupSequence("idle_unarmed") end
    if seq > 0 then
        ent:ResetSequence(seq)
        return
    end

    for _, name in ipairs(ent:GetSequenceList()) do
        local n = name:lower()
        if n ~= "idlenoise" and (n:find("idle") or n:find("fly")) then
            ent:ResetSequence(name)
            return
        end
    end

    ent:ResetSequence(4)
    hook.Run("OnModelPanelSetup", self)
end

local mX, mY = gui.MouseX, gui.MouseY
function PANEL:LayoutEntity()
    local xR, yR = mX() / ScrW(), mY() / ScrH()
    local x = select(1, self:LocalToScreen(self:GetWide() / 2))
    local xR2 = x / ScrW()
    local ent = self.Entity
    ent:SetPoseParameter("head_pitch", yR * 90 - 30)
    ent:SetPoseParameter("head_yaw", (xR - xR2) * 90 - 5)
    ent:SetAngles(Angle(0, 45, 0))
    ent:SetIK(false)
    if self.copyLocalSequence then
        local ply = LocalPlayer()
        ent:SetSequence(ply:GetSequence())
        ent:SetPoseParameter("move_yaw", 360 * ply:GetPoseParameter("move_yaw") - 180)
    end

    self:RunAnimation()
end

function PANEL:PreDrawModel(ent)
    local b = self.brightness
    if b then
        local b1, b2 = b * 0.4, b * 1.5
        render.SetModelLighting(0, b2, b2, b2)
        for i = 1, 4 do
            render.SetModelLighting(i, b1, b1, b1)
        end

        local f = b1 * 0.1
        render.SetModelLighting(5, f, f, f)
    end

    if self.enableHook then hook.Run("DrawLiliaModelView", self, ent) end
    return true
end

function PANEL:PostDrawModel(ent)
    if ent.Bonemerge then
        for _, v in ipairs(ent.Bonemerge) do
            if IsValid(v) then v:DrawModel() end
        end
    end
end

function PANEL:OnMousePressed()
end

function PANEL:fitFOV()
    local ent = self:GetEntity()
    if not IsValid(ent) then return end
    local mins, maxs = ent:GetRenderBounds()
    local h = math.abs(maxs.z) + math.abs(mins.z) + 8
    local d = self:GetCamPos():Length()
    self:SetFOV(math.deg(2 * math.atan(h / (2 * d))))
end

vgui.Register("liaModelPanel", PANEL, "DModelPanel")
