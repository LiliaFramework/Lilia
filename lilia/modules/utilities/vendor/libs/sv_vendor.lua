local MODULE = MODULE
local EDITOR = {}
EDITOR.name = function(vendor, _)
    local name = net.ReadString()
    vendor:setName(name)
end

EDITOR.desc = function(vendor, _)
    local desc = net.ReadString()
    vendor:setDesc(desc)
end

EDITOR.mode = function(vendor, _)
    local itemType = net.ReadString()
    local mode = net.ReadInt(8)
    vendor:setTradeMode(itemType, mode)
end

EDITOR.price = function(vendor, _)
    local itemType = net.ReadString()
    local price = net.ReadInt(32)
    vendor:setItemPrice(itemType, price)
end

EDITOR.stockDisable = function(vendor, _)
    local itemType = net.ReadString()
    vendor:setMaxStock(itemType, nil)
end

EDITOR.stockMax = function(vendor, _)
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor:setMaxStock(itemType, value)
end

EDITOR.stock = function(vendor, _)
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor:setStock(itemType, value)
end

EDITOR.faction = function(vendor, _)
    local factionID = net.ReadUInt(8)
    local allowed = net.ReadBool()
    vendor:setFactionAllowed(factionID, allowed)
end

EDITOR.class = function(vendor, _)
    local classID = net.ReadUInt(8)
    local allowed = net.ReadBool()
    vendor:setClassAllowed(classID, allowed)
end

EDITOR.model = function(vendor, _)
    local model = net.ReadString()
    vendor:setModel(model)
end

EDITOR.useMoney = function(vendor, _)
    local useMoney = net.ReadBool()
    if useMoney then
        vendor:setMoney(MODULE.DefaultVendorMoney)
    else
        vendor:setMoney(nil)
    end
end

EDITOR.money = function(vendor, _, _, _)
    local money = net.ReadUInt(32)
    vendor:setMoney(money)
end

EDITOR.scale = function(vendor, _)
    local scale = net.ReadFloat()
    vendor:setSellScale(scale)
end
return EDITOR