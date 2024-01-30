---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.DrawTexture(material, color, x, y, w, h)
    surface.SetDrawColor(color or color_white)
    surface.SetMaterial(lia.util.getMaterial(material))
    surface.DrawTexturedRect(x, y, w, h)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.SkinFunc(name, panel, a, b, c, d, e, f, g)
    local skin = (ispanel(panel) and IsValid(panel)) and panel:GetSkin() or derma.GetDefaultSkin()
    if not skin then return end
    local func = skin[name]
    if not func then return end
    return func(skin, panel, a, b, c, d, e, f, g)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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
            if w > maxW then maxW = w end
        end
    end

    if line ~= "" then lines[#lines + 1] = line end
    return lines, maxW
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.notify(message)
    chat.AddText(message)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.notifyLocalized(message, ...)
    lia.util.notify(L(message, ...))
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.drawBlur(panel, amount, passes)
    amount = amount or 5
    if useCheapBlur then
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.getInjuredColor(client)
    local health_color = color_white
    if not IsValid(client) then return health_color end
    local health, healthMax = client:Health(), client:GetMaxHealth()
    if (health / healthMax) < .95 then health_color = lia.color.LerpHSV(nil, nil, healthMax, health, 0) end
    return health_color
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.ScreenScaleH(n, type)
    if type then
        if ScrH() > 720 then return n end
        return math.ceil(n / 1080 * ScrH())
    end
    return n * (ScrH() / 480)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
timer.Create("liaResolutionMonitor", 1, 0, function()
    local scrW, scrH = ScrW(), ScrH()
    if scrW ~= LAST_WIDTH or scrH ~= LAST_HEIGHT then
        hook.Run("ScreenResolutionChanged", LAST_WIDTH, LAST_HEIGHT)
        LAST_WIDTH = scrW
        LAST_HEIGHT = scrH
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function Derma_NumericRequest(strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText)
    local Window = vgui.Create("DFrame")
    Window:SetTitle(strTitle or "Message Title (First Parameter)")
    Window:SetDraggable(false)
    Window:ShowCloseButton(false)
    Window:SetBackgroundBlur(true)
    Window:SetDrawOnTop(true)
    local InnerPanel = vgui.Create("DPanel", Window)
    InnerPanel:SetPaintBackground(false)
    local Text = vgui.Create("DLabel", InnerPanel)
    Text:SetText(strText or "Message Text (Second Parameter)")
    Text:SizeToContents()
    Text:SetContentAlignment(5)
    Text:SetTextColor(color_white)
    local TextEntry = vgui.Create("DTextEntry", InnerPanel)
    TextEntry:SetValue(strDefaultText or "")
    TextEntry.OnEnter = function()
        Window:Close()
        fnEnter(TextEntry:GetValue())
    end

    TextEntry:SetNumeric(true)
    local ButtonPanel = vgui.Create("DPanel", Window)
    ButtonPanel:SetTall(30)
    ButtonPanel:SetPaintBackground(false)
    local Button = vgui.Create("DButton", ButtonPanel)
    Button:SetText(strButtonText or "OK")
    Button:SizeToContents()
    Button:SetTall(20)
    Button:SetWide(Button:GetWide() + 20)
    Button:SetPos(5, 5)
    Button.DoClick = function()
        Window:Close()
        fnEnter(TextEntry:GetValue())
    end

    local ButtonCancel = vgui.Create("DButton", ButtonPanel)
    ButtonCancel:SetText(strButtonCancelText or L"derma_request_cancel")
    ButtonCancel:SizeToContents()
    ButtonCancel:SetTall(20)
    ButtonCancel:SetWide(Button:GetWide() + 20)
    ButtonCancel:SetPos(5, 5)
    ButtonCancel.DoClick = function()
        Window:Close()
        if fnCancel then fnCancel(TextEntry:GetValue()) end
    end

    ButtonCancel:MoveRightOf(Button, 5)
    ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)
    local w, h = Text:GetSize()
    w = math.max(w, 400)
    Window:SetSize(w + 50, h + 25 + 75 + 10)
    Window:Center()
    InnerPanel:StretchToParent(5, 25, 5, 45)
    Text:StretchToParent(5, 5, 5, 35)
    TextEntry:StretchToParent(5, nil, 5, nil)
    TextEntry:AlignBottom(5)
    TextEntry:RequestFocus()
    TextEntry:SelectAllText(true)
    ButtonPanel:CenterHorizontal()
    ButtonPanel:AlignBottom(8)
    Window:MakePopup()
    Window:DoModal()
    return Window
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
file.CreateDir("lilia/images")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.util.LoadedImages = lia.util.LoadedImages or {
    [0] = Material("icon16/cross.png")
}

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.util.FetchImage(id, callback, failImg, pngParameters, imageProvider)
    failImg = failImg
    local loadedImage = lia.util.LoadedImages[id]
    if loadedImage then
        if callback then callback(loadedImage) end
        return
    end

    if file.Exists("lilia/images/" .. id .. ".png", "DATA") then
        local mat = Material("data/lilia/images/" .. id .. ".png", pngParameters or "noclamp smooth")
        if mat then
            lia.util.LoadedImages[id] = mat
            if callback then callback(mat) end
        elseif callback then
            callback(false)
        end
    else
        http.Fetch((imageProvider or "https://i.imgur.com/") .. id .. ".png", function(body, size, headers, code)
            if code ~= 200 then
                callback(false)
                return
            end

            if not body or body == "" then
                callback(false)
                return
            end

            file.Write("lilia/images/" .. id .. ".png", body)
            local mat = Material("data/lilia/images/" .. id .. ".png", "noclamp smooth")
            lia.util.LoadedImages[id] = mat
            if callback then callback(mat) end
        end, function() if callback then callback(false) end end)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
cvars.AddChangeCallback("lia_cheapblur", function(name, old, new) useCheapBlur = (tonumber(new) or 0) > 0 end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
