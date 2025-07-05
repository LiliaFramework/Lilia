lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
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
        lia.include(directory .. "/" .. v, "shared")
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            ErrorNoHalt("Class '" .. niceName .. "' does not have a valid faction!\n")
            CLASS = nil
            continue
        end

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

function lia.class.canBe(client, class)
    local info = lia.class.list[class]
    if not info then return false, L("classNoInfo") end
    if client:Team() ~= info.faction then return false, L("classWrongTeam") end
    if client:getChar():getClass() == class then return false, L("alreadyInClass") end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, L("classFull") end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    if info.OnCanBe and not info:OnCanBe(client) then return false end
    return info.isDefault
end

function lia.class.get(identifier)
    return lia.class.list[identifier]
end

function lia.class.getPlayers(class)
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then table.insert(players, v) end
    end
    return players
end

function lia.class.getPlayerCount(class)
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then count = count + 1 end
    end
    return count
end

function lia.class.retrieveClass(class)
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end

function lia.class.hasWhitelist(class)
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    return info.isWhitelisted
end
