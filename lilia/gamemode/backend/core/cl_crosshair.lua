--------------------------------------------------------------------------------------------------------------------------
local function drawdot(pos, size, col)
    pos[1] = math.Round(pos[1])
    pos[2] = math.Round(pos[2])
    draw.RoundedBox(0, pos[1] - size / 2, pos[2] - size / 2, size, size, col[1])
    size = size - 2
    draw.RoundedBox(0, pos[1] - size / 2, pos[2] - size / 2, size, size, col[2])
end

--------------------------------------------------------------------------------------------------------------------------
function GM:HUDPaintCrosshair()
    local client = LocalPlayer()
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local wep = client:GetActiveWeapon()
    if not (client:IsValid() and client:Alive() and client:getChar()) or entity:IsValid() then return end
    if not (wep and wep:IsValid()) then return end
    if lia.config.NoDrawCrosshairWeapon[wep:GetClass()] then return end
    if hook.Run("ShouldDrawCrosshair") == false or g_ContextMenu:IsVisible() or IsValid(lia.gui.character) and lia.gui.character:IsVisible() then return end
    local t = util.QuickTrace(client:GetShootPos(), client:GetAimVector() * 15000, client)
    local pos = t.HitPos:ToScreen()
    local col = {color_white, color_white}
    drawdot({pos.x, pos.y}, 3, col)
end
--------------------------------------------------------------------------------------------------------------------------