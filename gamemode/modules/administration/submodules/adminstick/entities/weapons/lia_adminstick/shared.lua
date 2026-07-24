SWEP.Author = "liliaplayer"
SWEP.Contact = "@liliaplayer"
SWEP.PrintName = "Staff Stick"
SWEP.Instructions = L("adminStickPurpose")
SWEP.Category = "Lilia"
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false
SWEP.IsAlwaysRaised = true
SWEP.Spawnable = true
SWEP.ViewModel = Model("models/weapons/v_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ModeDefinitions = SWEP.ModeDefinitions or {}
SWEP.ModeOrder = SWEP.ModeOrder or {}
function SWEP:RegisterMode(id, definition)
    assert(isstring(id) and id ~= "", "Admin stick mode requires an id")
    assert(istable(definition), "Admin stick mode requires a definition")
    if not self.ModeDefinitions[id] then self.ModeOrder[#self.ModeOrder + 1] = id end
    self.ModeDefinitions[id] = definition
end

function SWEP:GetAvailableModes(client)
    local modes = {}
    for _, id in ipairs(self.ModeOrder) do
        local definition = self.ModeDefinitions[id]
        if definition and (not definition.CanUse or definition.CanUse(client, self)) then modes[#modes + 1] = id end
    end
    return modes
end

function SWEP:GetModeDefinition(id)
    return self.ModeDefinitions[id or self.ActiveMode]
end

function SWEP:GetActiveMode()
    local modes = self:GetAvailableModes(LocalPlayer())
    if not table.HasValue(modes, self.ActiveMode) then self.ActiveMode = modes[1] end
    return self.ActiveMode, self:GetModeDefinition(self.ActiveMode)
end

function SWEP:CycleMode()
    local modes = self:GetAvailableModes(LocalPlayer())
    if #modes < 2 then return false end
    local current = table.KeyFromValue(modes, self.ActiveMode) or 1
    local oldDefinition = self:GetModeDefinition(self.ActiveMode)
    if oldDefinition and oldDefinition.OnExit then oldDefinition.OnExit(self) end
    self.ActiveMode = modes[current % #modes + 1]
    local _, definition = self:GetActiveMode()
    if definition and definition.OnEnter then definition.OnEnter(self) end
    return true
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:DrawModel()
        return
    end

    if owner:GetMoveType() == MOVETYPE_NOCLIP then return end
    self:DrawModel()
end

function SWEP:Initialize()
    self:SetHoldType("melee")
end
