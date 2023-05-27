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

--///////////// EXTRA /////////////// 
function NutDrawBlur(panel, amount, passes)
    lia.util.drawBlur(panel, amount, passes)
end

function NutDrawBlurAt(x, y, w, h, amount, passes)
    lia.util.drawBlurAt(x, y, w, h, amount, passes)
end

function NutDrawText(text, x, y, color, alignX, alignY, font, alpha)
    lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
end

function NutWrapText(text, width, font)
    lia.util.wrapText(text, width, font)
end

function NutNotify(message)
    lia.util.notify(message)
end

function NutNotifyLocalized(message, ...)
    lia.util.notifyLocalized(message, ...)
end

function NutEmitQueueSounds(entity, sounds, delay, spacing, volume, pitch)
    lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
end

function NutStringMatches(a, b)
    lia.util.stringMatches(a, b)
end

function NutGetUTCTime()
    lia.util.getUTCTime()
end

function NutGetStringTime(text)
    lia.util.getStringTime(text)
end

function NutDateToNumber(str)
    lia.util.dateToNumber(str)
end