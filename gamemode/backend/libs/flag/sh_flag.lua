--------------------------------------------------------------------------------------------------------
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--------------------------------------------------------------------------------------------------------
lia.flag.defaultlist = {
    ["c"] = "Access to spawn chairs.",
    ["C"] = "Access to spawn vehicles.",
    ["W"] = "Access to spawn SWEPS.",
    ["E"] = "Access to spawn SENTs.",
    ["L"] = "Access to spawn Effects.",
    ["r"] = "Access to spawn ragdolls.",
    ["e"] = "Access to spawn props.",
    ["n"] = "Access to spawn NPCs.",
    ["P"] = "Access to PAC3.",
    ["p"] = "Access to the physgun.",
    ["t"] = "Access to the toolgun."
}
--------------------------------------------------------------------------------------------------------
function lia.flag.add(flag, desc, callback)
    lia.flag.list[flag] = {
        desc = desc,
        callback = callback
    }
end
--------------------------------------------------------------------------------------------------------
for desc, flag in pairs(lia.flag.defaultlist) do
    lia.flag.add(flag, desc)
end
--------------------------------------------------------------------------------------------------------