PLUGIN.name = "Server Blacklister"
PLUGIN.author = "Leonheart#7476"
PLUGIN.desc = "A Player Blacklister."
lia.util.include("sv_plugin.lua")
lia.util.include("cl_plugin.lua")

PLUGIN.Blacklist = {
    IPAddress = {"86.172.101.19", "0.0.0.0", "1.1.1.1"},
    SteamID = {"STEAM_0:0:539872789", "STEAM_0:1:67558546"}
}