local PANEL = {}
local function setSequence(entity)
    local seq = entity:SelectWeightedSequence(ACT_IDLE)
    if seq <= 0 then seq = entity:LookupSequence("idle_unarmed") end
    entity:SetIK(false)
    if seq > 0 then
        entity:ResetSequence(seq)
        return
    end

    for _, name in ipairs(entity:GetSequenceList()) do
        local lname = name:lower()
        if lname ~= "idlenoise" and (lname:find("idle") or lname:find("fly")) then
            entity:ResetSequence(name)
            return
        end
    end

    entity:ResetSequence(4)
end

function PANEL:Init()
    self:setHidden(false)
    for i = 0, 5 do
        self:SetDirectionalLight(i, (i == 1 or i == 5) and Color(155, 155, 155) or Color(255, 255, 255))
    end

    local oldSetModel = self.SetModel
    self.SetModel = function(panel, model, skin)
        oldSetModel(panel, model)
        local entity = panel.Entity
        if skin then entity:SetSkin(skin) end
        if panel.ItemTable then
            local paintMat = hook.Run("PaintItem", panel.ItemTable)
            if isstring(paintMat) and paintMat ~= "" then
                entity:SetMaterial(paintMat)
            elseif isstring(panel.ItemTable.material) and panel.ItemTable.material ~= "" then
                entity:SetMaterial(panel.ItemTable.material)
            else
                entity:SetMaterial("")
            end
        end

        setSequence(entity)
        local data = PositionSpawnIcon(entity, entity:GetPos())
        if data then
            panel:SetFOV(data.fov)
            panel:SetCamPos(data.origin)
            panel:SetLookAng(data.angles)
        end

        entity:SetEyeTarget(Vector(0, 0, 64))
    end
end

function PANEL:setHidden(hidden)
    if hidden then
        self:SetAmbientLight(color_black)
        self:SetColor(Color(0, 0, 0))
    else
        self:SetAmbientLight(Color(20, 20, 20))
        self:SetAlpha(255)
        self:SetColor(Color(255, 255, 255))
    end

    for i = 0, 5 do
        self:SetDirectionalLight(i, hidden and color_black or (i == 1 or i == 5) and Color(155, 155, 155) or Color(255, 255, 255))
    end
end

function PANEL:LayoutEntity()
    self:RunAnimation()
end

function PANEL:OnMousePressed()
    if self.DoClick then self:DoClick() end
end

vgui.Register("liaSpawnIcon", PANEL, "DModelPanel")