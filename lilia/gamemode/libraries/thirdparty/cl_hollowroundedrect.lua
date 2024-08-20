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
        --draw.RoundedBox(cornerRadius, x + thickness, y + thickness, w - thickness * 2, h - thickness * 2, surface.GetDrawColor())
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
