netstream.Hook("doorMenu", function(entity, access, door2)
    if IsValid(lia.gui.door) then return lia.gui.door:Remove() end
    if IsValid(entity) then
        lia.gui.door = vgui.Create("liaDoorMenu")
        lia.gui.door:setDoor(entity, access, door2)
    end
end)

netstream.Hook("doorPerm", function(door, client, access)
    local panel = door.liaPanel
    if IsValid(panel) and IsValid(client) then
        panel.access[client] = access
        for _, v in ipairs(panel.access:GetLines()) do
            if v.player == client then
                v:SetColumnText(2, L(ACCESS_LABELS[access or 0]))
                return
            end
        end
    end
end)
