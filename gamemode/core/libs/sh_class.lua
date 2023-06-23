lia.class = lia.class or {}
lia.class.list = {}

-- Register classes from a directory.
function lia.class.loadFromDir(directory)
    -- Search the directory for .lua files.
    for k, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        -- Get the name without the "sh_" prefix and ".lua" suffix.
        local niceName = v:sub(4, -5)
        -- Determine a numeric identifier for this class.
        local index = #lia.class.list + 1
        local halt

        for k, v in ipairs(lia.class.list) do
            if v.uniqueID == niceName then
                halt = true
            end
        end

        if halt == true then continue end

        -- Set up a global table so the file has access to the class table.
        CLASS = {
            index = index,
            uniqueID = niceName
        }

        -- Define some default variables.
        CLASS.name = "Unknown"
        CLASS.desc = "No description available."
        CLASS.limit = 0

        -- For future use with plugins.
        if PLUGIN then
            CLASS.plugin = PLUGIN.uniqueID
        end

        -- Include the file so data can be modified.
        lia.util.include(directory .. "/" .. v, "shared")

        -- Why have a class without a faction?
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            ErrorNoHalt("Class '" .. niceName .. "' does not have a valid faction!\n")
            CLASS = nil
            continue
        end

        -- Allow classes to be joinable by default.
        if not CLASS.onCanBe then
            CLASS.onCanBe = function(client) return true end
        end

        -- Add the class to the list of classes.
        lia.class.list[index] = CLASS
        -- Remove the global variable to prevent conflict.
        CLASS = nil
    end
end

-- Determines if a player is allowed to join a specific class.
function lia.class.canBe(client, class)
    -- Get the class table by its numeric identifier.
    local info = lia.class.list[class]
    -- See if the class exists.
    if not info then return false, "no info" end
    -- If the player's faction matches the class's faction.
    if client:Team() ~= info.faction then return false, "not correct team" end
    if client:getChar():getClass() == class then return false, "same class request" end

    if info.limit > 0 then
        if #lia.class.getPlayers(info.index) >= info.limit then return false, "class is full" end
    end

    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    -- See if the class allows the player to join it.

    return info:onCanBe(client)
end

function lia.class.get(identifier)
    return lia.class.list[identifier]
end

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

local charMeta = lia.meta.character

function charMeta:joinClass(class, isForced)
    if not class then
        self:kickClass()

        return
    end

    local oldClass = self:getClass()
    local client = self:getPlayer()

    if isForced or lia.class.canBe(client, class) then
        self:setClass(class)
        hook.Run("OnPlayerJoinClass", client, class, oldClass)

        return true
    else
        return false
    end
end

function charMeta:kickClass()
    local client = self:getPlayer()
    if not client then return end
    local goClass

    for k, v in pairs(lia.class.list) do
        if v.faction == client:Team() and v.isDefault then
            goClass = k
            break
        end
    end

    self:joinClass(goClass)
    hook.Run("OnPlayerJoinClass", client, goClass)
end

function charMeta:JoinClass(class, isForced)
    self:joinClass(class, isForced)
end

function charMeta:KickClass()
    self:kickClass()
end

function GM:PlayerJoinedClass(client, class, oldClass)
    self:OnPlayerJoinClass(client, class, oldClass)
end

function GM:OnPlayerJoinClass(client, class, oldClass)
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]

    if info.onSet then
        info:onSet(client)
    end

    if info2 and info2.onLeave then
        info2:onLeave(client)
    end

    netstream.Start(nil, "classUpdate", client)
end