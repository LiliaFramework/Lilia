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
            nut = nut or {}
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
            nut.config.add = NutConfigAdd
            nut.config.setDefault = NutConfigSetDefault
            nut.config.forceSet = NutConfigForceSet
            nut.config.set = NutConfigSet
            nut.config.get = NutConfigGet
            print("[COMPATIBILITY] FOUND NUT!")
        elseif isIxGlobalUsed() then
            ix = ix or {}
            ix.util = ix.util or {}
            ix.data = ix.data or {}
            ix.config = ix.config or {}
            ix.config.stored = ix.config.stored or {}
            ix.data.Set = HelixDataSet
            ix.data.Set = HelixDataGet
            ix.data.Delete = HelixDataDelete
            ix.util.Include = HelixIncludeFile
            ix.util.IncludeDir = HelixIncludeFile
            ix.util.GetAdmins = HelixGetAdmins
            ix.util.IsSteamID = HelixIsSteamID
            ix.util.FindPlayer = HelixFindPlayer
            ix.util.GridVector = HelixGetGridVector
            ix.util.GetMaterial = HelixGetMaterial
            ix.config.Add = HelixConfigAdd
            ix.config.SetDefault = HelixConfigSetDefault
            ix.config.ForceSet = HelixConfigForceSet
            ix.config.Set = HelixConfigSet
            ix.config.Get = HelixConfigGet
            print("[COMPATIBILITY] FOUND IX!")
    end)
end