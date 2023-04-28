TIME = TIME or {}

function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    local character = ply:getChar()
    local width, height = ScrW(), ScrH()
    local format = "%A, %d %B " .. tostring(lia.config.get("SchemaYear", 2023))
    local xOF = 400
    local y = 50
    local timer = 0
    if not character then return end
    if not lia.config.get("TimeOnScreenEnabled", false) then return end

    if timer < CurTime() then
        timer = CurTime() + 0.5
        surface.SetFont("MAIN_Font32")
        y = y + 12
        y = y + 26
        TIME.DrawShadowText("Current Date: " .. os.date(format, lia.date.get()), width - xOF, y, nil, false)
        y = y + 21
    end
end

function TIME.DrawShadowText(txt, x, y, c, centered)
    TIME.ColorShadow = Color(255, 255, 255)
    surface.SetTextColor(TIME.ColorShadow)
    local width, height = surface.GetTextSize(txt)
    x = x - (centered and (width / 2) or 0)
    surface.SetTextPos(x + 2, y + 2)
    surface.DrawText(txt)
end