function MODULE:ShouldDrawCrosshair()
    local client = LocalPlayer()
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local wep = client:GetActiveWeapon()
    if not client:getChar() then return false end
    if IsValid(wep) then
        local className = wep:GetClass()
        if className == "gmod_tool" or string.find(className, "lia_") or string.find(className, "detector_") then return true end
        if not self.NoDrawCrosshairWeapon[wep:GetClass()] and self.CrosshairEnabled and IsValid(client) and client:Alive() and client:getChar() and not IsValid(entity) and wep and not (g_ContextMenu:IsVisible() or IsValid(lia.gui.character) and lia.gui.character:IsVisible()) then return true end
    end
end

function MODULE:DrawCrosshair()
    local client = LocalPlayer()
    local t = util.QuickTrace(client:GetShootPos(), client:GetAimVector() * 15000, client)
    if t.HitPos then
        local pos = t.HitPos:ToScreen()
        local col = {color_white, color_white}
        local size = 3
        if pos then
            pos[1] = math.Round(pos[1] or 0)
            pos[2] = math.Round(pos[2] or 0)
            draw.RoundedBox(0, pos[1] - size / 2, pos[2] - size / 2, size, size, col[1])
            size = size - 2
            draw.RoundedBox(0, pos[1] - size / 2, pos[2] - size / 2, size, size, col[2])
        end
    end
end
