---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local data = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local offset1, offset2, offset3, alpha, y
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:StartChat()
    net.Start("liaTypeStatus")
    net.WriteBool(false)
    net.SendToServer()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:FinishChat()
    net.Start("liaTypeStatus")
    net.WriteBool(true)
    net.SendToServer()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:HUDPaint()
    local client = LocalPlayer()
    local ourPos = client:GetPos()
    local time = RealTime() * 5
    data.start = client:EyePos()
    data.filter = client
    for _, v in ipairs(player.GetAll()) do
        if v ~= client and v:getNetVar("typing", false) and v:GetMoveType() == MOVETYPE_WALK then
            data.endpos = v:EyePos()
            if util.TraceLine(data).Entity ~= v then continue end
            local position = v:GetPos()
            alpha = (1 - (ourPos:DistToSqr(position) / 65536)) * 255
            if alpha <= 0 then continue end
            local screen = (position + (v:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
            offset1 = math.sin(time + 2) * alpha
            offset2 = math.sin(time + 1) * alpha
            offset3 = math.sin(time) * alpha
            y = screen.y - 20
            lia.util.drawText("•", screen.x - 8, y, ColorAlpha(Color(250, 250, 250), offset1), 1, 1, "liaChatFont", offset1)
            lia.util.drawText("•", screen.x, y, ColorAlpha(Color(250, 250, 250), offset2), 1, 1, "liaChatFont", offset2)
            lia.util.drawText("•", screen.x + 8, y, ColorAlpha(Color(250, 250, 250), offset3), 1, 1, "liaChatFont", offset3)
        end
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------