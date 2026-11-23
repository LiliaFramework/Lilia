local sitroom = MODULE

function sitroom:CanManage(client)
    return IsValid(client) and client:IsPlayer() and client:hasPrivilege("manageSitRooms") or false
end

function sitroom:CanUseCommand(client, command)
    if not self:CanManage(client) then return false end
    return client:hasPrivilege("command_" .. string.lower(command))
end

function sitroom:NormalizeName(name)
    return isstring(name) and name or ""
end

function sitroom:GetRooms()
    local rooms = lia.data.get(self.DataKey, {})
    return istable(rooms) and rooms or {}
end

function sitroom:SaveRooms(rooms)
    lia.data.set(self.DataKey, istable(rooms) and rooms or {})
end

function sitroom:SetRoom(name, pos)
    name = self:NormalizeName(name)
    if name == "" or not isvector(pos) then return false end
    local rooms = self:GetRooms()
    rooms[name] = pos
    self:SaveRooms(rooms)
    return true
end

function sitroom:RemoveRoomAtPosition(pos)
    if not isvector(pos) then return false end
    local rooms = self:GetRooms()
    for name, roomPos in pairs(rooms) do
        if isvector(roomPos) and roomPos:DistToSqr(pos) < 1 then
            rooms[name] = nil
            self:SaveRooms(rooms)
            return true
        end
    end
    return false
end

function sitroom:Teleport(target, pos, rememberPosition)
    if not IsValid(target) or not target:IsPlayer() or not isvector(pos) then return false end
    if rememberPosition then target.previousSitroomPos = target:GetPos() end
    target:SetPos(pos)
    return true
end

function sitroom:Return(target)
    if not IsValid(target) or not target:IsPlayer() or not isvector(target.previousSitroomPos) then return false end
    target:SetPos(target.previousSitroomPos)
    return true
end

lia.util.setPositionCallback("Sit Room", {
    canAccess = function(client)
        return sitroom:CanManage(client)
    end,
    formatLabel = function(label)
        return string.format("Sit Room %s", label)
    end,
    onRun = function(pos, client)
        if SERVER then
            if not sitroom:CanManage(client) then return end
            local name = net.ReadString()
            if sitroom:SetRoom(name, pos) then client:notifySuccess("Administration Room has been set!") end
        else
            if not sitroom:CanManage(client) then return end
            client:requestString("Enter Name", "Enter the name of the Administration Room(" .. "):", function(name)
                if name == false then return end
                name = sitroom:NormalizeName(name)
                if name == "" then
                    client:notifyError("Invalid name!")
                    return
                end

                net.Start("liaSetFeaturePosition")
                net.WriteString(sitroom.PositionType)
                net.WriteVector(pos)
                net.WriteString(name)
                net.SendToServer()
            end)
        end
    end,
    onSelect = function(client, callback)
        if SERVER then
            if not sitroom:CanManage(client) then
                callback({}, 0)
                return
            end

            local rooms = sitroom:GetRooms()
            local list = {}
            for name, pos in pairs(rooms) do
                if isvector(pos) then
                    list[#list + 1] = {
                        pos = pos,
                        label = name
                    }
                end
            end

            callback(list, #list)
        else
            if not sitroom:CanManage(client) then
                callback({}, 0)
                return
            end

            net.Start("liaFeaturePositionsRequest")
            net.WriteString(sitroom.PositionType)
            net.SendToServer()
        end
    end,
    onRemove = function(pos, client)
        if SERVER and sitroom:CanManage(client) then sitroom:RemoveRoomAtPosition(pos) end
    end,
    color = sitroom.PositionColor,
    serverOnly = true
})
