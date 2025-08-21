DeriveGamemode("sandbox")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("core/libraries/loader.lua")
include("shared.lua")
DeriveGamemode("sandbox")
for _, netString in ipairs(networkStrings) do
    util.AddNetworkString(netString)
end