net.Receive("liaDoorMenu", function()
    if net.BytesLeft() > 0 then
        local entity = net.ReadEntity()
        local count = net.ReadUInt(8)
        local access = {}
        for _ = 1, count do
            local ply = net.ReadEntity()
            local perm = net.ReadUInt(2)
            access[ply] = perm
        end
        local door2 = net.ReadEntity()
        if IsValid(lia.gui.door) then return lia.gui.door:Remove() end
        if IsValid(entity) then
            lia.gui.door = vgui.Create("liaDoorMenu")
            lia.gui.door:setDoor(entity, access, door2)
        end
    elseif IsValid(lia.gui.door) then
        lia.gui.door:Remove()
    end
end)
net.Receive("liaDoorPerm", function()
    local door = net.ReadEntity()
    local client = net.ReadEntity()
    local access = net.ReadUInt(2)
    local panel = door.liaPanel
    if IsValid(panel) and IsValid(client) then
        panel.access[client] = access
        for _, v in ipairs(panel.access:GetLines()) do
            if v.player == client then
                v:SetColumnText(2, L(lia.doors.AccessLabels[access or 0]))
                return
            end
        end
    end
end)