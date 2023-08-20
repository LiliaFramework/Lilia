ICON = {}
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
function WB:ColorBrighten(col)
    return Color(col.r + 10, col.g + 10, col.b + 10, col.a)
end

function WB:StyleButton(pnl, hoverCol, idleCol, roundCorners, smoothHover)
    AccessorFunc(pnl, "color", "Color")
    pnl:SetColor(idleCol)
    if smoothHover or false then
        function pnl:OnCursorEntered()
            self:ColorTo(hoverCol, 0.2, 0)
        end

        function pnl:OnCursorExited()
            self:ColorTo(idleCol, 0.2, 0)
        end
    end

    function pnl:Paint(w, h)
        draw.RoundedBox(roundCorners, 0, 0, w, h, self:GetColor())
    end
end

function draw.Circle(x, y, radius, seg)
    local cir = {}
    table.insert(
        cir,
        {
            x = x,
            y = y,
            u = 0.5,
            v = 0.5
        }
    )

    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(
            cir,
            {
                x = x + math.sin(a) * radius,
                y = y + math.cos(a) * radius,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            }
        )
    end

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(
        cir,
        {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        }
    )

    surface.DrawPoly(cir)
end

function CreateOverBlur(callback)
    local blur = vgui.Create("DPanel")
    blur:SetSize(ScrW(), ScrH())
    blur:Center()
    blur:MakePopup()
    blur:SetAlpha(0)
    blur:AlphaTo(255, 0.15, 0, function() if callback then callback(blur) end end)
    function blur:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
        lia.util.drawBlur(self, 6)
    end

    --No focus for me!
    function blur:Think()
        if self:HasFocus() then
            local c = self:GetChildren()
            if #c > 0 then c[1]:MakePopup() end
        end
    end

    function blur:OnKeyCodePressed(key)
        if key == KEY_F1 then self:Remove() end
    end

    function blur:SmoothClose()
        self:AlphaTo(0, 0.2, 0.15, function() self:Remove() end)
    end
    return blur
end

function follow(pnl1, pnl2, side)
    side = side or BOTTOM
    if side == BOTTOM then
        local p2x, p2y = pnl2:GetPos()
        pnl1:SetPos(p2x, p2y + pnl2:GetTall() + 10)
    elseif side == LEFT then
        pnl1:SetPos(pnl2:GetX() - pnl1:GetWide() - 5, pnl1:GetY() - pnl1:GetTall() / 4)
    elseif side == RIGHT then
        pnl1:SetPos(pnl2:GetX() + pnl2:GetWide(), pnl2:GetY() - pnl1:GetTall() / 4)
    end
end

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

if CLIENT then end
local playerMeta = FindMetaTable("Player")