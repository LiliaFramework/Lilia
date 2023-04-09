local PLUGIN = PLUGIN

-- Called when the player is sending client info.
function PLUGIN:PlayerInitialSpawn(client)
    -- Send the list of text displays.
    timer.Simple(1, function()
        if IsValid(client) then
            netstream.Start(client, "txtList", self.list)
        end
    end)
end

-- Adds a text to the list, sends it to the players, and saves data.
function PLUGIN:addText(position, angles, text, scale)
    -- Find an ID for this text within the list of texts.
    local index = #self.list + 1
    -- Play with the numbers to get a 3D2D scale.
    scale = math.Clamp((scale or 1) * 0.1, 0.001, 5)

    -- Add the text to the list of texts so it can be sent and saved.
    self.list[index] = {position, angles, text, scale}

    -- Send the text information to the players.
    netstream.Start(nil, "txt", index, position, angles, text, scale)
    -- Save the plugin data.
    self:SaveText()
end

-- Removes a text that are within the radius of a position.
function PLUGIN:removeText(position, radius)
    -- Store how many texts are removed.
    local i = 0
    -- Default the radius to 100.
    radius = radius or 100

    -- Loop through all of the texts.
    for k, v in pairs(self.list) do
        -- Check if the distance from our specified position to the text is less than the radius.
        if v[1]:Distance(position) <= radius then
            -- Remove the text from the list of texts.
            self.list[k] = nil
            -- Tell the players to stop showing the text.
            netstream.Start(nil, "txt", k)
            -- Increase the number of deleted texts by one.
            i = i + 1
        end
    end

    -- Save the plugin data if we actually changed anything.
    if i > 0 then
        self:SaveText()
    end
    -- Return the number of deleted texts.

    return i
end

-- Called after entities have been loaded on the map.
function PLUGIN:LoadData()
    self.list = self:getData() or {}
end

-- Called when the plugin needs to save information.
function PLUGIN:SaveText()
    self:setData(self.list)
end