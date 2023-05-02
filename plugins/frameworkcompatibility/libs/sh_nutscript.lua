--///////////// DATA /////////////// 
function NutDataSet(key, value, global, ignoreMap)
    lia.data.set(key, value, global, ignoreMap)
end

function NutDataGet(key, default, global, ignoreMap, refresh)
    lia.data.get(key, default, global, ignoreMap, refresh)
end

function NutDataDelete(key, default, global, ignoreMap, refresh)
    lia.data.delete(key, global, ignoreMap)
end

--///////////// UTIL /////////////// 
function NutIncludeFile(fileName, state)
    lia.util.include(fileName, state)
end

function NutIncludeDir(directory, fromLua, recursive)
    lia.util.includeDir(directory, fromLua, recursive)
end

function NutGetAdmins(isSuper)
    lia.util.getAdmins(isSuper)
end

function NutIsSteamID(value)
    lia.util.isSteamID(value)
end

function NutFindPlayer(identifier, bAllowPatterns)
    lia.util.findPlayer(identifier, allowPatterns)
end

function NutGetGridVector(vec, gridSize)
    lia.util.gridVector(vec, gridSize)
end

function NutGetMaterial(materialPath)
    lia.util.getMaterial(materialPath)
end

--///////////// CONFIG /////////////// 
function NutConfigAdd(key, value, desc, callback, data, noNetworking, schemaOnly)
    lia.config.add(key, value, desc, callback, data, noNetworking, schemaOnly)
end

function NutConfigSetDefault(key, value)
    lia.config.setDefault(key, value)
end

function NutConfigForceSet(key, value, noSave)
    lia.config.forceSet(key, value, noSave)
end

function NutConfigSet(key, value)
    lia.config.set(key, value)
end

function NutConfigGet(key, default)
    lia.config.get(key, default)
end

