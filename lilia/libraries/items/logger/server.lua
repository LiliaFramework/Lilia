lia.log.addType("itemTake", function(client, ...)
    local data = {...}
    local itemName = data[1] or "unknown"
    local itemCount = data[2] or 1
    return string.format("%s has picked up %dx%s.", client:Name(), itemCount, itemName)
end)

lia.log.addType("itemDrop", function(client, ...)
    local data = {...}
    local itemName = data[1] or "unknown"
    local itemCount = data[2] or 1
    return string.format("%s has lost %dx%s.", client:Name(), itemCount, itemName)
end)

lia.log.addType("itemUse", function(client, ...)
    local arg = {...}
    local item = arg[2]
    return Format("%s tried '%s' on item '%s'(#%s)", client:Name(), arg[1], item.name, item.id)
end)
