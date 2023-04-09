AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Bodygroup Closet"
ENT.Category = "Lilia"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
    function ENT:Initialize()
        self:SetModel("models/props_wasteland/controlroom_storagecloset001a.mdl")
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:Wake()
        end
    end

    function ENT:Use(client)
        netstream.Start(client, "lia_bodygroupclosetopenmenu")
        self:EmitSound(lia.config.get("closet_open_sound", "items/ammocrate_open.wav"))
    end
else
    ENT.DrawEntityInfo = true

    function ENT:onDrawEntityInfo(alpha)
        local pos = self:LocalToWorld(self:OBBCenter()):ToScreen()
        lia.util.drawText(lia.config.get("closet_name", "Bodygroup Closet"), pos.x, pos.y, ColorAlpha(lia.config.get("color", Color(255, 255, 255)), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function ENT:Draw()
        self:DrawModel()
    end
end