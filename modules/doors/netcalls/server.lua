net.Receive("doorPerm", function(_, client)
    local door = net.ReadEntity()
    local target = net.ReadEntity()
    local access = net.ReadUInt(2)
    if IsValid(target) and target:getChar() and door.liaAccess and door:GetDTEntity(0) == client and target ~= client then
        access = math.Clamp(access or 0, DOOR_NONE, DOOR_TENANT)
        if access == door.liaAccess[target] then return end
        door.liaAccess[target] = access
        local recipient = {}
        for k, v in pairs(door.liaAccess) do
            if v > DOOR_GUEST then recipient[#recipient + 1] = k end
        end

        if #recipient > 0 then
            net.Start("doorPerm")
            net.WriteEntity(door)
            net.WriteEntity(target)
            net.WriteUInt(access, 2)
            net.Send(recipient)
        end
    end
end)
