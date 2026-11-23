local sitroom = MODULE

net.Receive("liaManagesitroomsAction", function(_, client)
    if not sitroom:CanManage(client) then return end
    local action = net.ReadUInt(2)
    local name = sitroom:NormalizeName(net.ReadString())
    if name == "" then return end

    local rooms = sitroom:GetRooms()
    if action == 1 then
        local targetPos = rooms[name]
        if not isvector(targetPos) or not sitroom:Teleport(client, targetPos, true) then return end
        client:notifySuccess(string.format("You have been teleported to Administration Room: %s.", name))
        local message = string.format("%s (Steam64ID: %s) teleported to sit room \"%s\".", client:Name(), client:SteamID64(), name)
        if isfunction(StaffAddTextShadowed) then StaffAddTextShadowed(sitroom.PositionColor, "SIT", Color(255, 255, 255), message) end
    elseif action == 2 then
        local newName = sitroom:NormalizeName(net.ReadString())
        if newName == "" or rooms[newName] or not rooms[name] then return end
        rooms[newName] = rooms[name]
        rooms[name] = nil
        sitroom:SaveRooms(rooms)
        client:notifySuccess("Administration Room renamed successfully.")
    elseif action == 3 then
        if not rooms[name] then return end
        rooms[name] = client:GetPos()
        sitroom:SaveRooms(rooms)
        client:notifySuccess("Administration Room repositioned successfully.")
    end
end)
