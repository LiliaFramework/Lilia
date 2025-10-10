lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
function lia.class.register(uniqueID, data)
    assert(isstring(uniqueID), L("classUniqueIDString"))
    assert(istable(data), L("classDataTable"))
    local index = #lia.class.list + 1
    local existing
    for i, v in ipairs(lia.class.list) do
        if v.uniqueID == uniqueID then
            index = i
            existing = v
            break
        end
    end

    local class = existing or {
        index = index
    }

    for k, v in pairs(data) do
        class[k] = v
    end

    class.uniqueID = uniqueID
    class.name = class.name or L("unknown")
    class.desc = class.desc or L("noDesc")
    class.limit = class.limit or 0
    if not class.faction or not team.Valid(class.faction) then
        lia.error(L("classNoValidFaction", uniqueID))
        return
    end

    if not class.OnCanBe then class.OnCanBe = function() return true end end
    lia.class.list[index] = class
    return class
end

function lia.class.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local index = #lia.class.list + 1
        local halt
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        for _, class in ipairs(lia.class.list) do
            if class.uniqueID == niceName then halt = true end
        end

        if halt then continue end
        CLASS = {
            index = index,
            uniqueID = niceName
        }

        CLASS.name = L("unknown")
        CLASS.desc = L("noDesc")
        CLASS.limit = 0
        lia.loader.include(directory .. "/" .. v, "shared")
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            lia.error(L("classNoValidFaction", niceName))
            CLASS = nil
            continue
        end

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        CLASS.name = L(CLASS.name)
        CLASS.desc = L(CLASS.desc)
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

function lia.class.canBe(client, class)
    if not lia.class.list then return false, L("classNoInfo") end
    local info = lia.class.list[class]
    if not info then return false, L("classNoInfo") end
    if client:Team() ~= info.faction then return false, L("classWrongTeam") end
    local character = client:getChar()
    if character and character:getClass() == class then return false, L("alreadyInClass") end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, L("classFull") end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    if info.OnCanBe and not info:OnCanBe(client) then return false end
    return info.isDefault
end

function lia.class.get(identifier)
    if not lia.class.list then return nil end
    return lia.class.list[identifier]
end

function lia.class.getPlayers(class)
    if not lia.class.list then return {} end
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then table.insert(players, v) end
    end
    return players
end

function lia.class.getPlayerCount(class)
    if not lia.class.list then return 0 end
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then count = count + 1 end
    end
    return count
end

function lia.class.retrieveClass(class)
    if not lia.class.list then return nil end
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end

function lia.class.hasWhitelist(class)
    if not lia.class.list then return false end
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    return info.isWhitelisted
end

function lia.class.retrieveJoinable(client)
    client = client or CLIENT and LocalPlayer() or nil
    if not IsValid(client) then return {} end
    if not lia.class.list then return {} end
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if lia.class.canBe(client, class.index) then classes[#classes + 1] = class end
    end
    return classes
end
