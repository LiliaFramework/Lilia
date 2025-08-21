lia.config.add("invW", "invWidth", 6, function(_, newW)
    if not SERVER then return end
    for _, client in player.Iterator() do
        if not IsValid(client) then continue end
        local char = client:getChar()
        if not char or char:getData("invSizeOverride") then continue end
        local inv = char:getInv()
        if not inv then continue end
        local dw, dh = hook.Run("GetDefaultInventorySize", client, char)
        dw = dw or lia.config.get("invW")
        dh = dh or lia.config.get("invH")
        local w, h = inv:getSize()
        if w ~= dw or h ~= dh then inv:setSize(dw, dh) end
        local removed = lia.inventory.checkOverflow(inv, char, w, h)
        if w ~= dw or h ~= dh or removed then inv:sync(client) end
    end

    local json = util.TableToJSON({newW})
    lia.db.query("UPDATE lia_invdata SET value = '" .. lia.db.escape(json) .. "' WHERE key = 'w' AND invID IN (SELECT invID FROM lia_inventories WHERE charID IS NOT NULL)")
end, {
    desc = "invWidthDesc",
    category = "character",
    type = "Int",
    min = 1,
    max = 20
})

lia.config.add("invH", "invHeight", 4, function(_, newH)
    if not SERVER then return end
    for _, client in player.Iterator() do
        if not IsValid(client) then continue end
        local char = client:getChar()
        if not char or char:getData("invSizeOverride") then continue end
        local inv = char:getInv()
        if not inv then continue end
        local dw, dh = hook.Run("GetDefaultInventorySize", client, char)
        dw = dw or lia.config.get("invW")
        dh = dh or lia.config.get("invH")
        local w, h = inv:getSize()
        if w ~= dw or h ~= dh then inv:setSize(dw, dh) end
        local removed = lia.inventory.checkOverflow(inv, char, w, h)
        if w ~= dw or h ~= dh or removed then inv:sync(client) end
    end

    local json = util.TableToJSON({newH})
    lia.db.query("UPDATE lia_invdata SET value = '" .. lia.db.escape(json) .. "' WHERE key = 'h' AND invID IN (SELECT invID FROM lia_inventories WHERE charID IS NOT NULL)")
end, {
    desc = "invHeightDesc",
    category = "character",
    type = "Int",
    min = 1,
    max = 20
})