--------------------------------------------------------------------------------------------------------
lia.class = lia.class or {}
lia.class.list = lia.class.list or {}

--------------------------------------------------------------------------------------------------------
function lia.class.loadFromDir(directory)
    for k, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(4, -5)
        local index = #lia.class.list + 1
        local halt

        for k, v in ipairs(lia.class.list) do
            if v.uniqueID == niceName then
                halt = true
            end
        end

        if halt == true then continue end

        CLASS = {
            index = index,
            uniqueID = niceName
        }

        CLASS.name = "Unknown"
        CLASS.desc = "No description available."
        CLASS.limit = 0

        if MODULE then
            CLASS.module = MODULE.uniqueID
        end

        lia.util.include(directory .. "/" .. v, "shared")

        if not CLASS.faction or not team.Valid(CLASS.faction) then
            ErrorNoHalt("Class '" .. niceName .. "' does not have a valid faction!\n")
            CLASS = nil
            continue
        end

        if not CLASS.onCanBe then
            CLASS.onCanBe = function(client)
                return true
            end
        end

        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

--------------------------------------------------------------------------------------------------------
function lia.class.canBe(client, class)
    local info = lia.class.list[class]
    if not info then return false, "no info" end
    if client:Team() ~= info.faction then return false, "not correct team" end
    if client:getChar():getClass() == class then return false, "same class request" end

    if info.limit > 0 then
        if #lia.class.getPlayers(info.index) >= info.limit then return false, "class is full" end
    end

    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end

    return info:onCanBe(client)
end

--------------------------------------------------------------------------------------------------------
function lia.class.get(identifier)
    return lia.class.list[identifier]
end

--------------------------------------------------------------------------------------------------------
function lia.class.getPlayers(class)
    local players = {}

    for k, v in ipairs(player.GetAll()) do
        local char = v:getChar()

        if char and char:getClass() == class then
            table.insert(players, v)
        end
    end

    return players
end
--------------------------------------------------------------------------------------------------------