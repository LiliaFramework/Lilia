--///////////// DATA /////////////// 
function HelixDataSet(key, value, global, ignoreMap)
    lia.data.set(key, value, global, ignoreMap)
end

function HelixDataGet(key, default, global, ignoreMap, refresh)
    lia.data.get(key, default, global, ignoreMap, refresh)
end

function HelixDataDelete(key, default, global, ignoreMap, refresh)
    lia.data.delete(key, global, ignoreMap)
end

--///////////// UTIL /////////////// 
function HelixIncludeFile(fileName, state)
    lia.util.include(fileName, state)
end

function HelixIncludeDir(directory, fromLua, recursive)
    lia.util.includeDir(directory, fromLua, recursive)
end

function HelixGetAdmins(isSuper)
    lia.util.getAdmins(isSuper)
end

function HelixIsSteamID(value)
    lia.util.isSteamID(value)
end

function HelixFindPlayer(identifier, bAllowPatterns)
    lia.util.findPlayer(identifier, allowPatterns)
end

function HelixGetGridVector(vec, gridSize)
    lia.util.gridVector(vec, gridSize)
end

function HelixGetMaterial(materialPath)
    lia.util.getMaterial(materialPath)
end

--///////////// CONFIG /////////////// 
function HelixConfigAdd(key, value, desc, callback, data, noNetworking, schemaOnly)
    lia.config.add(key, value, desc, callback, data, noNetworking, schemaOnly)
end

function HelixConfigSetDefault(key, value)
    lia.config.setDefault(key, value)
end

function HelixConfigForceSet(key, value, noSave)
    lia.config.forceSet(key, value, noSave)
end

function HelixConfigSet(key, value)
    lia.config.set(key, value)
end

function HelixConfigGet(key, default)
    lia.config.get(key, default)
end