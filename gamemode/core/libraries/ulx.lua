local hooksToRemove = {{"CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess"}, {"CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess"}, {"CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered"}, {"CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved"}, {"CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged"}, {"CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged"}, {"CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered"}, {"PlayerSay", "ULXMeCheck"}}
for _, hookPair in ipairs(hooksToRemove) do
    hook.Remove(hookPair[1], hookPair[2])
end