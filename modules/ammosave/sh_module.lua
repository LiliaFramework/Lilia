lia.ammo = lia.ammo or {}
MODULE.ammoList = {}
MODULE.name = "Ammo Saver"
MODULE.author = "Leonheart#7476/Black Tea"
MODULE.desc = "Saves the ammo of a character."
lia.util.include("sv_module.lua")
function lia.ammo.register(name)
    table.insert(MODULE.ammoList, name)
end

lia.ammo.register("ar2")
lia.ammo.register("pistol")
lia.ammo.register("357")
lia.ammo.register("smg1")
lia.ammo.register("xbowbolt")
lia.ammo.register("buckshot")
lia.ammo.register("rpg_round")
lia.ammo.register("smg1_grenade")
lia.ammo.register("grenade")
lia.ammo.register("ar2altfire")
lia.ammo.register("slam")
lia.ammo.register("alyxgun")
lia.ammo.register("sniperround")
lia.ammo.register("sniperpenetratedround")
lia.ammo.register("thumper")
lia.ammo.register("gravity")
lia.ammo.register("battery")
lia.ammo.register("gaussenergy")
lia.ammo.register("combinecannon")
lia.ammo.register("airboatgun")
lia.ammo.register("striderminigun")
lia.ammo.register("helicoptergun")
local ammo = {
    ["7.92x33mm Kurz"] = "ar2",
    ["300 AAC Blackout"] = "ar2",
    ["5.7x28mm"] = "ar2",
    ["7.62x25mm Tokarev"] = "smg1",
    [".50 BMG"] = "ar2",
    ["5.56x45mm"] = "ar2",
    ["7.62x51mm"] = "ar2",
    ["7.62x31mm"] = "ar2",
    ["Frag Grenades"] = "grenade",
    ["Flash Grenades"] = "grenade",
    ["Smoke Grenades"] = "grenade",
    ["9x17MM"] = "pistol",
    ["9x19MM"] = "pistol",
    ["9x19mm"] = "pistol",
    [".45 ACP"] = "pistol",
    ["9x18MM"] = "pistol",
    ["9x39MM"] = "pistol",
    [".40 S&W"] = "pistol",
    [".44 Magnum"] = "357",
    [".50 AE"] = "357",
    ["5.45x39MM"] = "ar2",
    ["5.56x45MM"] = "ar2",
    ["5.7x28MM"] = "ar2",
    ["7.62x51MM"] = "ar2",
    ["7.62x54mmR"] = "ar2",
    ["12 Gauge"] = "buckshot",
    [".338 Lapua"] = "sniperround",
}

for k, v in pairs(ammo) do
    lia.ammo.register(v)
    lia.ammo.register(k)
end