local EDITOR = {}
EDITOR.name = function(vendor)
    local name = net.ReadString()
    vendor:setName(name)
end

EDITOR.mode = function(vendor)
    local itemType = net.ReadString()
    local mode = net.ReadInt(8)
    vendor:setTradeMode(itemType, mode)
end

EDITOR.price = function(vendor)
    local itemType = net.ReadString()
    local price = net.ReadInt(32)
    vendor:setItemPrice(itemType, price)
end

EDITOR.flag = function(vendor)
    local flag = net.ReadString()
    vendor:setNetVar("flag", flag)
end

EDITOR.stockDisable = function(vendor)
    local itemType = net.ReadString()
    vendor:setMaxStock(itemType, nil)
end

EDITOR.welcome = function(vendor)
    local message = net.ReadString()
    vendor:setWelcomeMessage(message)
end

EDITOR.stockMax = function(vendor)
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor:setMaxStock(itemType, value)
end

EDITOR.stock = function(vendor)
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor:setStock(itemType, value)
end

EDITOR.faction = function(vendor)
    local factionID = net.ReadUInt(8)
    local allowed = net.ReadBool()
    vendor:setFactionAllowed(factionID, allowed)
end

EDITOR.class = function(vendor)
    local classID = net.ReadUInt(8)
    local allowed = net.ReadBool()
    vendor:setClassAllowed(classID, allowed)
end

EDITOR.model = function(vendor)
    local model = net.ReadString()
    vendor:setModel(model)
end

EDITOR.useMoney = function(vendor)
    local useMoney = net.ReadBool()
    if useMoney then
        vendor:setMoney(lia.config.get("vendorDefaultMoney", 500))
    else
        vendor:setMoney(nil)
    end
end

EDITOR.money = function(vendor)
    local money = net.ReadUInt(32)
    vendor:setMoney(money)
end

EDITOR.scale = function(vendor)
    local scale = net.ReadFloat()
    vendor:setSellScale(scale)
end
return EDITOR
