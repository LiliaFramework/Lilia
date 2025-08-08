lia.config.add("invW", L("invWidth"), 6, function(_, newW)
    if not SERVER then return end
    for _, client in player.Iterator() do
        if not IsValid(client) then continue end
        local inv = client:getChar():getInv()
        local dw, dh = hook.Run("GetDefaultInventorySize", client)
        dw = dw or newW
        dh = dh or lia.config.get("invH")
        local w, h = inv:getSize()
        if w ~= dw or h ~= dh then
            inv:setSize(dw, dh)
            inv:sync(client)
        end
    end

    local json = util.TableToJSON({newW})
    lia.db.query("UPDATE lia_invdata SET value = '" .. lia.db.escape(json) .. "' " .. "WHERE key = 'w' AND invID IN (SELECT invID FROM lia_inventories WHERE charID IS NOT NULL)")
end, {
    desc = L("invWidthDesc"),
    category = L("character"),
    type = "Int",
    min = 1,
    max = 10
})

lia.config.add("invH", L("invHeight"), 4, function(_, newH)
    if not SERVER then return end
    for _, client in player.Iterator() do
        if not IsValid(client) then continue end
        local inv = client:getChar():getInv()
        local dw, dh = hook.Run("GetDefaultInventorySize", client)
        dw = dw or lia.config.get("invW")
        dh = dh or newH
        local w, h = inv:getSize()
        if w ~= dw or h ~= dh then
            inv:setSize(dw, dh)
            inv:sync(client)
        end
    end

    local json = util.TableToJSON({newH})
    lia.db.query("UPDATE lia_invdata SET value = '" .. lia.db.escape(json) .. "' " .. "WHERE key = 'h' AND invID IN (SELECT invID FROM lia_inventories WHERE charID IS NOT NULL)")
end, {
    desc = L("invHeightDesc"),
    category = L("character"),
    type = "Int",
    min = 1,
    max = 10
})