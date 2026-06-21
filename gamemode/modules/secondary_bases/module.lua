MODULE.name = "secondaryBases"
MODULE.author = "copilot"
MODULE.desc = "Secondary Bases management and spawn integration"
MODULE.NetworkStrings = {
    "liaSecondaryBases_Sync",
    "liaSecondaryBases_RequestList",
    "liaSecondaryBases_Toggle",
    "liaSecondaryBases_Remove",
    "liaSecondaryBases_Create",
    "liaSecondaryBases_MapViewRequest",
    "liaSecondaryBases_MapViewResponse",
    "liaSecondaryBases_RequestAvailable",
    "liaSecondaryBases_Available",
    "liaSecondaryBases_Select"
}

if SERVER then
    if util and util.AddNetworkString then
        for _, s in ipairs(MODULE.NetworkStrings) do
            util.AddNetworkString(s)
        end
    end
end
