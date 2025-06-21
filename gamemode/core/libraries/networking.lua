lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
if SERVER then
    function checkBadType(name, object)
        if isfunction(object) then
            ErrorNoHalt("Net var '" .. name .. "' contains a bad object type!")
            return true
        elseif istable(object) then
            for k, v in pairs(object) do
                if checkBadType(name, k) or checkBadType(name, v) then return true end
            end
        end
    end

    --[[
        setNetVar(key, value, receiver)

        Description:
            Stores a global network variable and broadcasts the new value
            to clients via the "gVar" netstream message.

        Parameters:
            key (string) – The unique identifier for the variable.
            value (any) – Value to assign. Functions and nested functions
            are disallowed.
            receiver (Player or table) – Optional receiver(s) for the update.
            Pass nil to broadcast to everyone.

        Realm:
            Server

        Returns:
            None
    ]]
    function setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        if getNetVar(key) == value then return end
        lia.net.globals[key] = value
        netstream.Start(receiver, "gVar", key, value)
    end

    --[[
        getNetVar(key, default)

        Description:
            Returns the value of a global network variable previously set
            with setNetVar.

        Parameters:
            key (string) – Name of the variable to read.
            default (any) – Value returned when the variable is nil.

        Realm:
            Shared

        Returns:
            any – The stored value or the provided default.
    ]]
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    hook.Add("EntityRemoved", "liaNetworkingCleanup", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "liaNetworkingSync", function(client) client:syncVars() end)
    hook.Add("CharDeleted", "liaNetworkingCharDeleted", function(client, character)
        lia.char.names[character:getID()] = nil
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)

    hook.Add("OnCharCreated", "liaNetworkingCharCreated", function(client, character, data)
        lia.char.names[character:getID()] = data.name
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)
else
    --[[
        getNetVar(key, default)

        Description:
            Client-side access to global variables synchronized from the server.

        Parameters:
            key (string) – Name of the variable to read.
            default (any) – Value returned when the variable is nil.

        Realm:
            Client

        Returns:
            any – The stored value or the provided default.
    ]]
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    --[[
        playerMeta.getLocalVar(key, default)

        Description:
            Alias for entityMeta.getNetVar available on the client. This
            allows code written for entities to work directly on the local
            player object.

        Parameters:
            key (string) – Name of the variable to read.
            default (any) – Value returned when the variable is nil.

        Realm:
            Client

        Returns:
            any – The stored value or the provided default.
    ]]
    playerMeta.getLocalVar = entityMeta.getNetVar
end
