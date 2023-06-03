function PLUGIN:LoadData()
    self.allowed = self:getData() or {}
end

function PLUGIN:SaveData()
    self:setData(self.allowed)
end

function PLUGIN:CheckPassword(steamID64)
    local steamID = util.SteamIDFrom64(steamID64)
    if lia.config.get("whitelistEnabled") and not self.allowed[steamID] then return false, "Sorry, you are not whitelisted for " .. GetHostName() end
end

function PLUGIN:PlayerAuthed(client, steamID, uniqueID)
    if lia.config.get("whitelistEnabled") and not self.allowed[steamID] then
        game.KickID(uniqueID, "Sorry, you are not whitelisted for " .. GetHostName())
    end
end