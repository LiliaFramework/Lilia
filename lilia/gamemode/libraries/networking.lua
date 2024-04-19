--- Networking helper functions
-- @module lia.net
lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
if SERVER then
    --- Checks if the provided object or any of its nested elements contain a bad type.
    -- @string name The name of the networked variable
    -- @param object The object to be checked for bad types
    -- @return True if a bad type is found, false otherwise
    -- @realm server
    -- @internal
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

    --- Sets the value of a networked global variable.
    -- @param key The key of the networked global variable
    -- @param value The value to set
    -- @client[opt] receiver The receiver of the network update
    -- @realm server
    function setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        if getNetVar(key) == value then return end
        lia.net.globals[key] = value
        netstream.Start(receiver, "gVar", key, value)
    end

    --- Retrieves the value of a networked global variable.
    -- @param key The key of the networked global variable
    -- @param default The default value to return if the variable is not found
    -- @return The value of the networked global variable, or the default value if not found
    -- @realm server
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    hook.Add("EntityRemoved", "nCleanUp", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "nSync", function(client) client:syncVars() end)
    hook.Add("liaCharDeleted", "liaCharRemoveName", function(client, character)
        lia.char.names[character:getID()] = nil
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)

    hook.Add("onCharCreated", "liaCharAddName", function(client, character, data)
        lia.char.names[character:getID()] = data.name
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)
else
    --- Retrieves the value of a networked global variable.
    -- @param key The key of the networked global variable
    -- @param default The default value to return if the variable is not found
    -- @return The value of the networked global variable, or the default value if not found
    -- @realm client
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end
