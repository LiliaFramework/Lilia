function isNutGlobalUsed()
    if nut then
        return true
    else
        return false
    end
end

function isIxGlobalUsed()
    if ix then
        return true
    else
        return false
    end
end

function isDarkRPGlobalUsed()
    if DarkRP then
        return true
    else
        return false
    end
end

function PLUGIN:InitializedPlugins()
    timer.Simple(3, function()
        print("STARTED COMPATIBILITY CHECK!")

        if isNutGlobalUsed() then
            nut = lia or {}
            --[[
            nut.util = nut.util or {}
            nut.data = nut.data or {}
            nut.config = nut.config or {}
            nut.config.stored = nut.config.stored or {}
            nut.data.set = NutDataSet
            nut.data.get = NutDataGet
            nut.data.delete = NutDataDelete
            nut.util.include = NutIncludeFile
            nut.util.includeDir = NutIncludeFile
            nut.util.getAdmins = NutGetAdmins
            nut.util.isSteamID = NutIsSteamID
            nut.util.findPlayer = NutFindPlayer
            nut.util.gridVector = NutGetGridVector
            nut.util.getMaterial = NutGetMaterial
            nut.util.drawBlur = NutDrawBlur
            nut.util.drawBlurAt = NutDrawBlurAt
            nut.util.drawText = NutDrawText
            nut.util.wrapText = NutWrapText
            nut.util.notify = NutNotify
            nut.util.notifyLocalized = NutNotifyLocalized
            nut.util.emitQueuedSounds = NutEmitQueueSounds
            nut.util.stringMatches = NutStringMatches
            nut.util.getUTCTime = NutGetUTCTime
            nut.util.getStringTime = NutGetStringTime
            nut.util.dateToNumber = NutDateToNumber
            nut.config.add = NutConfigAdd
            nut.config.setDefault = NutConfigSetDefault
            nut.config.forceSet = NutConfigForceSet
            nut.config.set = NutConfigSet
            nut.config.get = NutConfigGet]]
            print("[COMPATIBILITY] FOUND NUT!")
        elseif isIxGlobalUsed() then
            ix = ix or {}
            ix.util = ix.util or {}
            ix.data = ix.data or {}
            ix.config = ix.config or {}
            ix.char = ix.char or {}
            ix.class = ix.class or {}
            ix.class.list = ix.class.list or {}
            ix.config.stored = ix.config.stored or {}
            ix.data.Set = HelixDataSet()
            ix.data.Set = HelixDataGet()
            ix.data.Delete = HelixDataDelete()
            ix.util.Include = HelixIncludeFile()
            ix.util.IncludeDir = HelixIncludeFile()
            ix.util.GetAdmins = HelixGetAdmins()
            ix.util.IsSteamID = HelixIsSteamID()
            ix.util.FindPlayer = HelixFindPlayer()
            ix.util.GridVector = HelixGetGridVector()
            ix.util.GetMaterial = HelixGetMaterial()
            ix.util.drawBlur = HelixDrawBlur()
            ix.util.drawBlurAt = HelixDrawBlurAt()
            ix.util.drawText = HelixDrawText()
            ix.util.wrapText = HelixWrapText()
            ix.util.notify = HelixNotify()
            ix.util.notifyLocalized = HelixNotifyLocalized()
            ix.util.emitQueuedSounds = HelixEmitQueueSounds()
            ix.util.stringMatches = HelixStringMatches()
            ix.util.getUTCTime = HelixGetUTCTime()
            ix.util.getStringTime = HelixGetStringTime()
            ix.util.dateToNumber = HelixDateToNumber()
            ix.config.Add = HelixConfigAdd()
            ix.config.SetDefault = HelixConfigSetDefault()
            ix.config.ForceSet = HelixConfigForceSet()
            ix.config.Set = HelixConfigSet()
            ix.config.Get = HelixConfigGet()
            ix.class.LoadFromDir = HelixLoadClass()
            ix.class.CanSwitchTo = HelixCanSwitchTo()
            ix.char.RegisterVar = HelixRegisterVar()
            ix.class.Get = HelixGetClass()
            ix.class.GetPlayers = HelixGetPlayers()
            print("[COMPATIBILITY] FOUND IX!")
        elseif isDarkRPGlobalUsed() then
            hook.Run("VerifyDarkRP")
            print("[COMPATIBILITY] FOUND DARKRP!")
        end

        print("Finished Loading!")
    end)
end