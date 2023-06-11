function PLUGIN:SetCompatibility()
    print("STARTED COMPATIBILITY CHECK!")

    if NSCompatibility then
        print("[COMPATIBILITY] FOUND NUT!")
        nut = lia or {}
        --[[
            lia.util = lia.util or {}
            lia.data = lia.data or {}
            lia.config = lia.config or {}
            lia.config.stored = lia.config.stored or {}
            lia.data.set = NutDataSet
            lia.data.get = NutDataGet
            lia.data.delete = NutDataDelete
            lia.util.include = NutIncludeFile
            lia.util.includeDir = NutIncludeFile
            lia.util.getAdmins = NutGetAdmins
            lia.util.isSteamID = NutIsSteamID
            lia.util.findPlayer = NutFindPlayer
            lia.util.gridVector = NutGetGridVector
            lia.util.getMaterial = NutGetMaterial
            lia.util.drawBlur = NutDrawBlur
            lia.util.drawBlurAt = NutDrawBlurAt
            lia.util.drawText = NutDrawText
            lia.util.wrapText = NutWrapText
            lia.util.notify = NutNotify
            lia.util.notifyLocalized = NutNotifyLocalized
            lia.util.emitQueuedSounds = NutEmitQueueSounds
            lia.util.stringMatches = NutStringMatches
            lia.util.getUTCTime = NutGetUTCTime
            lia.util.getStringTime = NutGetStringTime
            lia.util.dateToNumber = NutDateToNumber
            lia.config.add = NutConfigAdd
            lia.config.setDefault = NutConfigSetDefault
            lia.config.forceSet = NutConfigForceSet
            lia.config.set = NutConfigSet
            lia.config.get = NutConfigGet]]
    elseif IXCompatibility then
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
    elseif DarkRPCompatibility then
        hook.Run("VerifyDarkRP")
        print("[COMPATIBILITY] FOUND DARKRP!")
    end

    print("Finished Loading!")
end

function PLUGIN:OnLoaded()
    self:SetCompatibility()
end
