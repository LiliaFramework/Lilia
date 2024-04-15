local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
function getNetVar(key, default)
    local value = lia.net.globals[key]
    return value ~= nil and value or default
end
playerMeta.getLocalVar = entityMeta.getNetVar