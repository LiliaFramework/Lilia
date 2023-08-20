WB = {}
WB.colors = {}
WB.colors.accentColor = Color(225, 75, 75)
WB.colors.darkL1 = Color(25, 25, 25)
WB.colors.darkL2 = Color(30, 30, 30)
WB.colors.darkL3 = Color(35, 35, 35)
BC_WARNING = Color(222, 217, 71)
BC_CRITICAL = Color(225, 75, 75)
BC_AGREE = Color(75, 225, 75)
BC_NEUTRAL = Color(206, 80, 80)
BC_NEUTRAL_HOV = Color(70, 163, 255)
NUTCOL = lia.config.Color

function getHovCol(col)
    if not col then return end

    return Color(col.r + 10, col.g + 10, col.b + 10, col.a)
end

function DebugPanel(pnl)
    function pnl:Paint(w, h)
        surface.SetDrawColor(255, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end
end

function strPosAngConv(str)
    local pos = str:Split(";")[1]:Split("setpos")[2]:Split(" ")
    pos = Vector(pos[2], pos[3], pos[4])
    local ang = str:Split(";")[2]:Split("setang")[2]:Split(" ")
    ang = Angle(ang[2], ang[3], ang[4])

    return pos, ang
end

WB.drawTextEntry = function(panel, w, h)
    local color = Color(235, 235, 235)

    if panel:IsEditing() then
        color = color_white
    else
        color = Color(235, 235, 235)
    end

    draw.RoundedBox(4, 0, 0, w, h, color)
    panel:DrawTextEntryText(color_black, Color(75, 75, 235), color_black)
end

if CLIENT then
    
end

local playerMeta = FindMetaTable("Player")

