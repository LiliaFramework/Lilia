--------------------------------------------------------------------------------------------------------
local LAST_WIDTH = ScrW()
local LAST_HEIGHT = ScrH()
--------------------------------------------------------------------------------------------------------
function lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
    color = color or color_white

    return draw.TextShadow({
        text = text,
        font = font or "liaGenericFont",
        pos = {x, y},
        color = color,
        xalign = alignX or 0,
        yalign = alignY or 0
    }, 1, alpha or (color.a * 0.575))
end
--------------------------------------------------------------------------------------------------------
function lia.util.wrapText(text, width, font)
    font = font or "liaChatFont"
    surface.SetFont(font)
    local exploded = string.Explode("%s", text, true)
    local line = ""
    local lines = {}
    local w = surface.GetTextSize(text)
    local maxW = 0

    if w <= width then
        text, _ = text:gsub("%s", " ")

        return {text}, w
    end

    for i = 1, #exploded do
        local word = exploded[i]
        line = line .. " " .. word
        w = surface.GetTextSize(line)

        if w > width then
            lines[#lines + 1] = line
            line = ""

            if w > maxW then
                maxW = w
            end
        end
    end

    if line ~= "" then
        lines[#lines + 1] = line
    end

    return lines, maxW
end
--------------------------------------------------------------------------------------------------------
function lia.util.notify(message)
    chat.AddText(message)
end
--------------------------------------------------------------------------------------------------------
function lia.util.notifyLocalized(message, ...)
    lia.util.notify(L(message, ...))
end
--------------------------------------------------------------------------------------------------------
function lia.util.drawBlur(panel, amount, passes)
    amount = amount or 5

    if CreateClientConVar("lia_cheapblur", 0, true):GetBool() then
        surface.SetDrawColor(50, 50, 50, amount * 20)
        surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
    else
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255)
        local x, y = panel:LocalToScreen(0, 0)

        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end
end
--------------------------------------------------------------------------------------------------------
function lia.util.drawBlurAt(x, y, w, h, amount, passes)
    amount = amount or 5

    if CreateClientConVar("lia_cheapblur", 0, true):GetBool() then
        surface.SetDrawColor(30, 30, 30, amount * 20)
        surface.DrawRect(x, y, w, h)
    else
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255)
        local scrW, scrH = ScrW(), ScrH()
        local x2, y2 = x / scrW, y / scrH
        local w2, h2 = (x + w) / scrW, (y + h) / scrH

        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
        end
    end
end
--------------------------------------------------------------------------------------------------------
timer.Create("liaResolutionMonitor", 1, 0, function()
    local scrW, scrH = ScrW(), ScrH()

    if scrW ~= LAST_WIDTH or scrH ~= LAST_HEIGHT then
        hook.Run("ScreenResolutionChanged", LAST_WIDTH, LAST_HEIGHT)
        LAST_WIDTH = scrW
        LAST_HEIGHT = scrH
    end
end)
--------------------------------------------------------------------------------------------------------