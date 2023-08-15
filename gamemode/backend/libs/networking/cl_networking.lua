--------------------------------------------------------------------------------------------------------
function getNetVar(key, default)
    local value = lia.net.globals[key]
    return value ~= nil and value or default
end

--------------------------------------------------------------------------------------------------------
FindMetaTable("Player").getLocalVar = FindMetaTable("Entity").getNetVar
--------------------------------------------------------------------------------------------------------