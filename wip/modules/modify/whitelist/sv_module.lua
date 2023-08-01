local CONFIG = CONFIG

function MODULE:LoadData()
    self.Allowed = self:getData() or {}
end

function MODULE:SaveData()
    self:setData(self.Allowed)
end

function MODULE:CheckPassword(steamID64)
    local steamID = util.SteamIDFrom64(steamID64)
    if self.whitelistEnabled and (not self.Allowed[steamID] or not CONFIG.AllowedOverride[steamID]) then return false, "Sorry, you are not whitelisted for " .. GetHostName() end
end

function MODULE:PlayerAuthed(client, steamID, uniqueID)
    if self.whitelistEnabled and (not self.Allowed[steamID] or not CONFIG.AllowedOverride[steamID]) then
        game.KickID(uniqueID, "Sorry, you are not whitelisted for " .. GetHostName())
    end

    en"someString"
end