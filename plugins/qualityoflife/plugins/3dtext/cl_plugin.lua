local PLUGIN = PLUGIN

-- Receives new text objects that need to be drawn.
netstream.Hook("txt", function(index, position, angles, text, scale)
    -- Check if we are adding or deleting the text.
    if position then
        -- Generate a markup object to draw fancy stuff for the text.
        local object = lia.markup.parse("<font=lia3D2DFont>" .. text:gsub("\\n", "\n"))

        -- We want to draw a shadow on the text object.
        object.onDrawText = function(text, font, x, y, color, alignX, alignY, alpha)
            surface.SetTextPos(x + 1, y + 1)
            surface.SetTextColor(0, 0, 0, alpha)
            surface.SetFont(font)
            surface.DrawText(text)
            surface.SetTextPos(x, y)
            surface.SetTextColor(color.r, color.g, color.b, alpha)
            surface.SetFont(font)
            surface.DrawText(text)
        end

        --draw.SimpleTextOutlined(text, font, x, y, ColorAlpha(color, alpha), alignX, alignY, 2, color_black)
        -- Add the text to a list of drawn text objects.
        PLUGIN.list[index] = {position, angles, object, scale}
    else
        -- Delete the text object if we are deleting stuff.
        PLUGIN.list[index] = nil
    end
end)

-- Receives a full update on ALL texts.
netstream.Hook("txtList", function(values)
    -- Set the list of texts to the ones provided by the server.
    PLUGIN.list = values

    -- Loop through the list of texts.
    for k, v in pairs(PLUGIN.list) do
        -- Generate markup object since it hasn't been done already.
        local object = lia.markup.parse("<font=lia3D2DFont>" .. v[3]:gsub("\\n", "\n"))

        -- Same thing with adding a shadow.
        object.onDrawText = function(text, font, x, y, color, alignX, alignY, alpha)
            draw.TextShadow({
                pos = {x, y},
                color = ColorAlpha(color, alpha),
                text = text,
                xalign = 0,
                yalign = alignY,
                font = font
            }, 1, alpha)
        end

        -- Set the text to have a markup object to draw.
        v[3] = object
    end
end)

-- Called after all translucent objects are drawn.
function PLUGIN:PostDrawTranslucentRenderables(drawingDepth, drawingSkyBox)
    if not drawingDepth and not drawingSkyBox then
        -- Store the position of the player to be more optimized.
        local position = LocalPlayer():GetPos()

        -- Loop through all of the text.
        for k, v in pairs(self.list) do
            -- Start a 3D2D camera at the text's position and angles.
            cam.Start3D2D(v[1], v[2], v[4] or 0.1)
            -- Calculate the distance from the player to the text.
            local distance = v[1]:Distance(position)

            -- Only draw the text if we are within 1024 units.
            if distance <= 1024 then
                -- Get the alpha that fades out as one moves farther from the text.
                local alpha = (1 - ((distance - 256) / 768)) * 255
                -- Draw the markup object.
                v[3]:draw(0, 0, 1, 1, alpha)
            end

            cam.End3D2D()
        end
    end
end