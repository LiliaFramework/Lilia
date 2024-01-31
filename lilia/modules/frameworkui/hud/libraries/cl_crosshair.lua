---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ShouldDrawCrosshair()
    local client = LocalPlayer()
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    if not self.CrosshairEnabled then return false end
    if not IsValid(client) or not client:Alive() or not client:getChar() or IsValid(entity) or (g_ContextMenu:IsVisible() or IsValid(lia.gui.character) and lia.gui.character:IsVisible()) then return false end
    local wep = client:GetActiveWeapon()
    if wep and IsValid(wep) then
        local className = wep:GetClass()
        if className == "gmod_tool" or string.find(className, "lia_") or string.find(className, "detector_") then return true end
        if self.NoDrawCrosshairWeapon[wep:GetClass()] then return false end
        return true
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:DrawCrosshair()
    local client = LocalPlayer()
    local t = util.QuickTrace(client:GetShootPos(), client:GetAimVector() * 15000, client)
    local pos = t.HitPos:ToScreen()
    local col = {color_white, color_white}
    local size = 3
    pos[1] = math.Round(pos[1])
    pos[2] = math.Round(pos[2])
    draw.RoundedBox(0, pos[1] - size / 2, pos[2] - size / 2, size, size, col[1])
    size = size - 2
    draw.RoundedBox(0, pos[1] - size / 2, pos[2] - size / 2, size, size, col[2])
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
