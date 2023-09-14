--------------------------------------------------------------------------------------------------------
function MODULE:AFKMonChanged(pl, isafk)
    if isafk == true or isafk == false or isafk == nil then
        client = id
        id = client:UserID()
        local TimeStamp_old = TimeStamp[id] and (SysTime() - TimeStamp[id]) or 0
        local TimeStamp_new = SysTime() - (isafk and lia.config.AFKTimer or 0)
        TimeStamp[id] = TimeStamp_new
        if CLIENT and client == LocalPlayer() then self:ClientAFKMonChanged() end
        hook.Run("AFK", client, isafk, id, TimeStamp_old, TimeStamp_new)
    end
end
--------------------------------------------------------------------------------------------------------
function MODULE:AFK(client, afk, id, len)
    if SERVER then
        self:ServerAFK(client, afk, id, len)
    else
        self:ClientAFK(client, afk, id, len)
    end
end
--------------------------------------------------------------------------------------------------------
function MODULE:OnPlayerAFKLong(client)
	local char = client:getChar()

	if (char) then
		
	end
end
--------------------------------------------------------------------------------------------------------