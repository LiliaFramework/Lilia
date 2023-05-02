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

--///////////// EXTRA /////////////// 
function HelixDrawBlur(panel, amount, passes)
    lia.util.drawBlur(panel, amount, passes)
end

function HelixDrawBlurAt(x, y, w, h, amount, passes)
    lia.util.drawBlurAt(x, y, w, h, amount, passes)
end

function HelixDrawText(text, x, y, color, alignX, alignY, font, alpha)
    lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
end

function HelixWrapText(text, width, font)
    lia.util.wrapText(text, width, font)
end

function HelixNotify(message)
    lia.util.notify(message)
end

function HelixNotifyLocalized(message, ...)
    lia.util.notifyLocalized(message, ...)
end

function HelixEmitQueueSounds(entity, sounds, delay, spacing, volume, pitch)
    lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
end

function HelixStringMatches(a, b)
    lia.util.stringMatches(a, b)
end

function HelixGetUTCTime()
    lia.util.getUTCTime()
end

function HelixGetStringTime(text)
    lia.util.getStringTime(text)
end

function HelixDateToNumber(str)
    lia.util.dateToNumber(str)
end

--///////////// CLASS /////////////// 
function HelixLoadClass(directory)
    lia.class.loadFromDir(directory)
end

function HelixGetClass(identifier)
    lia.class.get(identifier)
end

function HelixGetPlayers(class)
    lia.class.getPlayers(class)
end

function HelixCanSwitchTo(client, class)
    lia.class.canBe(client, class)
end

--///////////// CHAR /////////////// 
function HelixRegisterVar(key, data)
    lia.char.registerVar(key, data)
end