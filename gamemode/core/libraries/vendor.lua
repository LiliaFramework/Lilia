lia.vendor = lia.vendor or {}
lia.vendor.editor = lia.vendor.editor or {}
lia.vendor.presets = lia.vendor.presets or {}
lia.vendor.rarities = lia.vendor.rarities or {}
if SERVER then
    lia.vendor.editor.name = function(vendor)
        local name = net.ReadString()
        vendor:setName(name)
    end

    lia.vendor.editor.mode = function(vendor)
        if vendor:getNetVar("preset") ~= "none" then return end
        local itemType = net.ReadString()
        local mode = net.ReadInt(8)
        vendor:setTradeMode(itemType, mode)
    end

    lia.vendor.editor.price = function(vendor)
        if vendor:getNetVar("preset") ~= "none" then return end
        local itemType = net.ReadString()
        local price = net.ReadInt(32)
        vendor:setItemPrice(itemType, price)
    end

    lia.vendor.editor.flag = function(vendor)
        local flag = net.ReadString()
        vendor:setNetVar("flag", flag)
    end

    lia.vendor.editor.stockDisable = function(vendor)
        if vendor:getNetVar("preset") ~= "none" then return end
        local itemType = net.ReadString()
        vendor:setMaxStock(itemType, nil)
    end

    lia.vendor.editor.welcome = function(vendor)
        local message = net.ReadString()
        vendor:setWelcomeMessage(message)
    end

    lia.vendor.editor.stockMax = function(vendor)
        if vendor:getNetVar("preset") ~= "none" then return end
        local itemType = net.ReadString()
        local value = net.ReadUInt(32)
        vendor:setMaxStock(itemType, value)
    end

    lia.vendor.editor.stock = function(vendor)
        if vendor:getNetVar("preset") ~= "none" then return end
        local itemType = net.ReadString()
        local value = net.ReadUInt(32)
        vendor:setStock(itemType, value)
    end

    lia.vendor.editor.faction = function(vendor)
        local factionID = net.ReadUInt(8)
        local allowed = net.ReadBool()
        vendor:setFactionAllowed(factionID, allowed)
    end

    lia.vendor.editor.class = function(vendor)
        local classID = net.ReadUInt(8)
        local allowed = net.ReadBool()
        vendor:setClassAllowed(classID, allowed)
    end

    lia.vendor.editor.model = function(vendor)
        local model = net.ReadString()
        vendor:setModel(model)
    end

    lia.vendor.editor.skin = function(vendor)
        local skin = net.ReadUInt(8)
        vendor:setSkin(skin)
    end

    lia.vendor.editor.bodygroup = function(vendor)
        local index = net.ReadUInt(8)
        local value = net.ReadUInt(8)
        vendor:setBodyGroup(index, value)
    end

    lia.vendor.editor.useMoney = function(vendor)
        local useMoney = net.ReadBool()
        if useMoney then
            vendor:setMoney(lia.config.get("vendorDefaultMoney", 500))
        else
            vendor:setMoney(nil)
        end
    end

    lia.vendor.editor.money = function(vendor)
        local money = net.ReadUInt(32)
        vendor:setMoney(money)
    end

    lia.vendor.editor.scale = function(vendor)
        local scale = net.ReadFloat()
        vendor:setSellScale(scale)
    end

    lia.vendor.editor.preset = function(vendor)
        local preset = net.ReadString()
        vendor:applyPreset(preset)
    end
else
    local function addEditor(name, callback)
        lia.vendor.editor[name] = function(...)
            net.Start("VendorEdit")
            net.WriteString(name)
            if isfunction(callback) then callback(...) end
            net.SendToServer()
        end
    end

    addEditor("mode", function(itemType, mode)
        if not isnumber(mode) then mode = nil end
        net.WriteString(itemType)
        net.WriteInt(mode or -1, 8)
    end)

    addEditor("price", function(itemType, price)
        net.WriteString(itemType)
        net.WriteInt(price or -1, 32)
    end)

    addEditor("stockDisable", function(itemType)
        net.WriteString(itemType)
        net.WriteUInt(0, 32)
    end)

    addEditor("stockMax", function(itemType, value)
        if not isnumber(value) then return end
        net.WriteString(itemType)
        net.WriteUInt(math.max(value, 1), 32)
    end)

    addEditor("stock", function(itemType, value)
        net.WriteString(itemType)
        net.WriteUInt(value, 32)
    end)

    addEditor("faction", function(factionID, allowed)
        net.WriteUInt(factionID, 8)
        net.WriteBool(allowed)
    end)

    addEditor("class", function(classID, allowed)
        net.WriteUInt(classID, 8)
        net.WriteBool(allowed)
    end)

    addEditor("money", function(value)
        if isnumber(value) then
            value = math.max(math.Round(value), 0)
        else
            value = nil
        end

        net.WriteInt(value or -1, 32)
    end)

    addEditor("flag", function(flag) net.WriteString(flag) end)
    addEditor("model", function(model) net.WriteString(model) end)
    addEditor("skin", function(skin) net.WriteUInt(math.Clamp(skin or 0, 0, 255), 8) end)
    addEditor("bodygroup", function(index, value)
        net.WriteUInt(index, 8)
        net.WriteUInt(value or 0, 8)
    end)

    addEditor("useMoney", function(useMoney) net.WriteBool(useMoney) end)
    addEditor("scale", function(scale) net.WriteFloat(scale) end)
    addEditor("name", function(name) net.WriteString(name) end)
    addEditor("welcome", function(message) net.WriteString(message) end)
    addEditor("preset", function(name) net.WriteString(name) end)
end

function lia.vendor.addRarities(name, color)
    assert(isstring(name), L("vendorRarityNameString"))
    assert(IsColor(color), L("vendorColorMustBeColor"))
    lia.vendor.rarities[name] = color
end

function lia.vendor.addPreset(name, items)
    assert(isstring(name), L("vendorPresetNameString"))
    assert(istable(items), L("vendorPresetItemsTable"))
    lia.vendor.presets[string.lower(name)] = items
end

function lia.vendor.getPreset(name)
    return lia.vendor.presets[string.lower(name)]
end
