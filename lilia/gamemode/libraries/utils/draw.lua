--- Draws text with a shadow effect.
-- @realm client
-- @string text The text to draw
-- @string font The font to use
-- @int x The x-coordinate to draw the text at
-- @int y The y-coordinate to draw the text at
-- @color colortext The color of the text
-- @color colorshadow The color of the shadow
-- @int dist The distance of the shadow from the text
-- @param xalign Horizontal alignment of the text (e.g., TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
-- @param yalign Vertical alignment of the text (e.g., TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
function draw.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    surface.SetFont(font)
    local _, h = surface.GetTextSize(text)
    
    if yalign == TEXT_ALIGN_CENTER then
        y = y - h / 2
    elseif yalign == TEXT_ALIGN_BOTTOM then
        y = y - h
    end
    
    draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
    draw.DrawText(text, font, x, y, colortext, xalign)
end

--- Draws text with an outline.
-- @realm client
-- @string text The text to draw
-- @string font The font to use
-- @int x The x-coordinate to draw the text at
-- @int y The y-coordinate to draw the text at
-- @color colour The color of the text
-- @param xalign Horizontal alignment of the text (e.g., TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT)
-- @int outlinewidth The width of the outline
-- @color outlinecolour The color of the outline
function draw.DrawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
    local steps = (outlinewidth * 2) / 3
    if steps < 1 then steps = 1 end
    
    for _x = -outlinewidth, outlinewidth, steps do
        for _y = -outlinewidth, outlinewidth, steps do
            draw.DrawText(text, font, x + _x, y + _y, outlinecolour, xalign)
        end
    end
    
    return draw.DrawText(text, font, x, y, colour, xalign)
end

--- Draws a tip box with text.
-- @realm client
-- @int x The x-coordinate of the top-left corner
-- @int y The y-coordinate of the top-left corner
-- @int w The width of the tip box
-- @int h The height of the tip box
-- @string text The text to display inside the tip box
-- @string font The font to use
-- @color textCol The color of the text
-- @color outlineCol The color of the outline
function draw.DrawTip(x, y, w, h, text, font, textCol, outlineCol)
    draw.NoTexture()
    local rectH = 0.85
    local triW = 0.1
    local verts = {
        {x = x, y = y},
        {x = x + w, y = y},
        {x = x + w, y = y + (h * rectH)},
        {x = x + (w / 2) + (w * triW), y = y + (h * rectH)},
        {x = x + (w / 2), y = y + h},
        {x = x + (w / 2) - (w * triW), y = y + (h * rectH)},
        {x = x, y = y + (h * rectH)}
    }
    
    surface.SetDrawColor(outlineCol)
    surface.DrawPoly(verts)
    draw.SimpleText(text, font, x + (w / 2), y + (h / 2), textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--- Adds an animated dot to a text string.
-- @realm client
-- @string text The base text to which dots will be added.
-- @number[opt] interval The interval in seconds at which dots change (default is 0.5).
function draw.DotDotDot(text, interval)
    interval = interval or 0.5
    local Dots = {"", ".", "..", "..."}
    
    draw.DotDotDotNextTime = draw.DotDotDotNextTime or CurTime()
    draw.DotDotDotIndex = draw.DotDotDotIndex or 1

    if CurTime() >= draw.DotDotDotNextTime then
        draw.DotDotDotNextTime = CurTime() + interval
        draw.DotDotDotIndex = draw.DotDotDotIndex + 1
        if draw.DotDotDotIndex > #Dots then
            draw.DotDotDotIndex = 1
        end
    end
    
    return text .. Dots[draw.DotDotDotIndex]
end