local PLUGIN = PLUGIN

-- Called when the player is sending client info.
function PLUGIN:PlayerInitialSpawn(client)
    -- Send the list of panel displays.
    timer.Simple(1, function()
        if IsValid(client) then
            netstream.Start(client, "panelList", self.list)
        end
    end)
end

-- Adds a panel to the list, sends it to the players, and saves data.
function PLUGIN:addPanel(position, angles, url, w, h, scale)
    w = w or 1024
    h = h or 768
    scale = math.Clamp((scale or 1) * 0.1, 0.001, 5)
    -- Find an ID for this panel within the list.
    local index = #self.list + 1

    -- Add the panel to the list so it can be sent and saved.
    self.list[index] = {position, angles, w, h, scale, url}

    -- Send the panel information to the players.
    netstream.Start(nil, "panel", index, position, angles, w, h, scale, url)
    -- Save the plugin data.
    self:SavePanels()
end

-- Removes a panel that are within the radius of a position.
function PLUGIN:removePanel(position, radius)
    -- Store how many panels are removed.
    local i = 0
    -- Default the radius to 100.
    radius = radius or 100

    -- Loop through all of the panels.
    for k, v in pairs(self.list) do
        -- Check if the distance from our specified position to the panel is less than the radius.
        if v[1]:Distance(position) <= radius then
            -- Remove the panel from the list of panels.
            self.list[k] = nil
            -- Tell the players to stop showing the panel.
            netstream.Start(nil, "panel", k)
            -- Increase the number of deleted panels by one.
            i = i + 1
        end
    end

    -- Save the plugin data if we actually changed anything.
    if i > 0 then
        self:SavePanels()
    end
    -- Return the number of deleted panels.

    return i
end

-- Called after entities have been loaded on the map.
function PLUGIN:LoadData()
    self.list = self:getData() or {}
end

-- Called when the plugin needs to save information.
function PLUGIN:SavePanels()
    self:setData(self.list)
end