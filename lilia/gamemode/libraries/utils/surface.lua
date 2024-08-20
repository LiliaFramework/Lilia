--- Helper library for generating bars.
-- @class surface

local WebMaterials = {}

--- Generates points for a rounded rectangle.
-- @param x The x-coordinate of the rectangle.
-- @param y The y-coordinate of the rectangle.
-- @param w The width of the rectangle.
-- @param h The height of the rectangle.
-- @param radius The corner radius of the rounded rectangle.
-- @return A table containing points for the rounded rectangle.
local function rounded_rectangle(x, y, w, h, radius)
    local polycount = 32
    if polycount % 4 > 0 then polycount = polycount + 4 - (polycount % 4) end
    local points, c, d, i = {}, {x + w / 2, y + h / 2}, {w / 2 - radius, radius - h / 2}, 0
    while i < polycount do
        local a = i * 2 * math.pi / polycount
        local p = {radius * math.cos(a), radius * math.sin(a)}
        for j = 1, 2 do
            table.insert(points, c[j] + d[j] + p[j])
            if p[j] * d[j] <= 0 and (p[1] * d[2] < p[2] * d[1]) then
                d[j] = d[j] * -1
                i = i - 1
            end
        end
        i = i + 1
    end
    return points
end

--- Draws an outlined rounded rectangle on the screen.
-- @param x The x-coordinate of the rectangle.
-- @param y The y-coordinate of the rectangle.
-- @param w The width of the rectangle.
-- @param h The height of the rectangle.
-- @param thickness The thickness of the outline.
-- @param cornerRadius The corner radius of the rounded rectangle.
function surface.DrawOutlinedRoundedRect(x, y, w, h, thickness, cornerRadius)
    thickness = thickness or 1
    cornerRadius = cornerRadius or 0
    if cornerRadius == 0 then
        surface.DrawOutlinedRect(x, y, w, h, thickness)
    else
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        local points = rounded_rectangle(x + thickness, y + thickness, w - thickness * 2, h - thickness * 2, cornerRadius)
        local poly = {}
        for i = 1, #points, 2 do
            table.insert(poly, {
                x = points[i],
                y = points[i + 1]
            })
        end
        surface.DrawPoly(poly)
        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        render.SetStencilFailOperation(STENCIL_KEEP)
        draw.RoundedBox(cornerRadius, x, y, w, h, surface.GetDrawColor())
        render.SetStencilEnable(false)
    end
end

--- Draws a blurred rectangle on the screen.
-- @param x The x-coordinate of the rectangle.
-- @param y The y-coordinate of the rectangle.
-- @param w The width of the rectangle.
-- @param h The height of the rectangle.
-- @param amount The amount of blur to apply.
-- @param heavyness The number of times the blur effect is applied.
-- @param alpha The alpha (transparency) value of the blur effect.
function surface.DrawBlurRect(x, y, w, h, amount, heavyness, alpha)
    local blur = Material("pp/blurscreen")
    local X, Y = 0, 0
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blur)
    for i = 1, heavyness do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawTexturedRect(X * -1, Y * -1, scrW, scrH)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

--- Retrieves a material from a URL, rendering it into a WebPanel.
-- @param url The URL of the web page to retrieve.
-- @param w The width of the WebPanel.
-- @param h The height of the WebPanel.
-- @param time The time duration before the WebPanel is removed.
-- @return The material created from the URL, or an error material if failed.
function surface.GetURL(url, w, h, time)
    if not url or not w or not h then return Material("error") end
    if WebMaterials[url] then return WebMaterials[url] end
    local WebPanel = vgui.Create("HTML")
    WebPanel:SetAlpha(0)
    WebPanel:SetSize(tonumber(w), tonumber(h))
    WebPanel:OpenURL(url)
    WebPanel.Paint = function(self)
        if not WebMaterials[url] and self:GetHTMLMaterial() then
            WebMaterials[url] = self:GetHTMLMaterial()
            self:Remove()
        end
    end

    timer.Simple(1 or tonumber(time), function()
        if IsValid(WebPanel) then WebPanel:Remove() end
    end)
    return Material("error")
end