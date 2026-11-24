local fontFiles = {"content/resource/fonts/montserrat-regular.ttf", "content/resource/fonts/montserrat-medium.ttf", "content/resource/fonts/montserrat-bold.ttf"}
local networkStrings = {"liaWeaponOverrideUpdate", "liaWeaponOverrideSync", "liaActBar", "liaAnimationStatus", "liaArgumentsRequest", "liaArgumentsRequestCancel", "liaAssureClientSideAssets", "liaAttributeData", "liaBigTableAck", "liaBinaryQuestionRequest", "liaBinaryQuestionRequestCancel", "liaPopupQuestionRequest", "liaBlindTarget", "liaButtonRequest", "liaCfgList", "liaCfgSet", "liaCharChoose", "liaCharCreate", "liaCharDelete", "liaCharInfo", "liaCharKick", "liaCharList", "liaCharRequest", "liaCharSet", "liaCharVar", "liaCharacterData", "liaCharacterInvList", "liaChatMsg", "liaCheckHack", "liaCheckSeed", "liaClassUpdate", "liaCmdArgPrompt", "liaCommandData", "liaDataSync", "liaDoorMenu", "liaDoorPerm", "liaDoorDataUpdate", "liaDoorDataBulk", "liaEmitUrlSound", "liaGlobalVar", "liaGroupPermChanged", "liaGroupsAdd", "liaGroupsRemove", "liaGroupsRename", "liaGroupsRequest", "liaGroupsSetPerm", "liaInsertKeyPressed", "liaInvAct", "liaInvData", "liaInvQuantity", "liaInventoryAdd", "liaInventoryData", "liaInventoryDelete", "liaInventoryInit", "liaInventoryRemove", "liaItemDelete", "liaItemInstance", "liaItemRotate", "liaKeybindServer", "liaMessageData", "liaNetDel", "liaNetLocal", "liaNetStreamData", "liaNetVar", "liaNotificationData", "liaNotifyLocal", "liaOpenInvMenu", "liaOptionsRequest", "liaOptionsRequestCancel", "liaPacPartAdd", "liaPacPartRemove", "liaPacPartReset", "liaPacSync", "liaPlayerInteractCategories", "liaPlayerInteractSync", "liaPlayerRespawn", "liaProvideInteractOptions", "liaRequestDropdown", "liaRequestDropdownCancel", "liaRequestInteractOptions", "liaReturnFromEntity", "liaRunInteraction", "liaCreateTableUI", "liaSeqSet", "liaServerChatAddText", "liaServerChatAddTextShadowed", "liaSetWaypoint", "liaSitSitFacing", "liaStaffDiscordResponse", "liaStorageSync", "liaStorageSyncRequest", "liaStringRequest", "liaStringRequestCancel", "liaWeaponRuntimeOverrideUpdate", "liaWeaponRuntimeOverrideSync", "liaWeaponRuntimeOverrideReset", "liaTeleportToEntity", "liaTransferItem", "ChangeAttribute", "liaUpdateAdminGroups", "liaUpdateAdminPrivileges", "liaVerifyCheatsResponse", "liaWaypointReached", "liaWorkshopDownloaderInfo", "liaWorkshopDownloaderRequest", "liaWorkshopDownloaderStart"}
DeriveGamemode("sandbox")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("core/libraries/core/loader.lua")
liaWorkshopRegisteredIDs = liaWorkshopRegisteredIDs or {}
liaWorkshopOriginalAddWorkshop = liaWorkshopOriginalAddWorkshop or resource.AddWorkshop
resource.AddWorkshop = function(id)
    local result = liaWorkshopOriginalAddWorkshop(id)
    local workshopID = tostring(id)
    if workshopID:match("^%d+$") and #workshopID <= 20 and workshopID ~= "0" then
        liaWorkshopRegisteredIDs[workshopID] = true
        hook.Run("liaWorkshopResourceRegistered", workshopID)
    end
    return result
end

include("shared.lua")
for _, fontFile in ipairs(fontFiles) do
    resource.AddSingleFile(fontFile)
end

for _, netString in ipairs(networkStrings) do
    util.AddNetworkString(netString)
end

resource.AddWorkshop("3527535922")
