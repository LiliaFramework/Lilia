
net.Receive("liaRestoreOverflowItems", function(_, client)
    local char = client:getChar()
    if not char then return end
    local data = char:getData("overflowItems")
    if not data or not data.items then return end
    local inv = char:getInv()
    if not inv then return end
    local dropPos = client:getItemDropPos()
    for _, itemInfo in ipairs(data.items) do
        local itemData = table.Copy(itemInfo.data or {})
        itemData.x, itemData.y = nil, nil
        inv:add(itemInfo.uniqueID, 1, itemData):next(function(item) if itemInfo.quantity and itemInfo.quantity > 1 then item:setQuantity(itemInfo.quantity) end end):catch(function() lia.item.spawn(itemInfo.uniqueID, dropPos, function(spawned) if spawned and itemInfo.quantity and itemInfo.quantity > 1 then spawned:setQuantity(itemInfo.quantity) end end, nil, itemInfo.data or {}) end)
    end

    char:setData("overflowItems", nil)
end)
