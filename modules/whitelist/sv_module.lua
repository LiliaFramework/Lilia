function MODULE:LoadData()
    self.allowed = self:getData() or {}
end

function MODULE:SaveData()
    self:setData(self.allowed)
end

function MODULE:CheckPassword(steamID64)
    local steamID = util.SteamIDFrom64(steamID64)
    if lia.config.WhitelistEnabled and not self.allowed[steamID] then return false, "Sorry, you are not whitelisted for " .. GetHostName() end
end

function MODULE:PlayerAuthed(client, steamID, uniqueID)
    if lia.config.WhitelistEnabled and not self.allowed[steamID] then
        game.KickID(uniqueID, "Sorry, you are not whitelisted for " .. GetHostName())
    end
end