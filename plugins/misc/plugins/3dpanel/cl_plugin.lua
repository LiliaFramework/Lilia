local PLUGIN = PLUGIN

-- Receives new panel objects that need to be drawn.
netstream.Hook("panel", function(index, position, angles, w, h, scale, url)
    -- Check if we are adding or deleting the panel.
    if position then
        -- Create a VGUI object to display the URL.
        local object = vgui.Create("DHTML")
        object:OpenURL(url)
        object:SetSize(w, h)
        object:SetKeyboardInputEnabled(false)
        object:SetMouseInputEnabled(false)
        object:SetPaintedManually(true)

        -- Add the panel to a list of drawn panel objects.
        PLUGIN.list[index] = {position, angles, w, h, scale, object}
    else
        -- Delete the panel object if we are deleting stuff.
        PLUGIN.list[index] = nil
    end
end)

-- Receives a full update on ALL panels.
netstream.Hook("panelList", function(values)
    -- Set the list of panels to the ones provided by the server.
    PLUGIN.list = values

    -- Loop through the list of panels.
    for k, v in pairs(PLUGIN.list) do
        -- Create a VGUI object to display the URL.
        local object = vgui.Create("DHTML")
        object:OpenURL(v[6])
        object:SetSize(v[3], v[4])
        object:SetKeyboardInputEnabled(false)
        object:SetMouseInputEnabled(false)
        object:SetPaintedManually(true)
        -- Set the panel to have a markup object to draw.
        v[6] = object
    end
end)

-- Called after all translucent objects are drawn.
function PLUGIN:PostDrawTranslucentRenderables(drawingDepth, drawingSkyBox)
    if not drawingDepth and not drawingSkyBox then
        -- Store the position of the player to be more optimized.
        local ourPosition = LocalPlayer():GetPos()

        -- Loop through all of the panel.
        for k, v in pairs(self.list) do
            local position = v[1]

            if ourPosition:DistToSqr(position) <= 4194304 then
                local panel = v[6]
                -- Start a 3D2D camera at the panel's position and angles.
                cam.Start3D2D(position, v[2], v[5] or 0.1)
                panel:SetPaintedManually(false)
                panel:PaintManual()
                panel:SetPaintedManually(true)
                cam.End3D2D()
            end
        end
    end
end