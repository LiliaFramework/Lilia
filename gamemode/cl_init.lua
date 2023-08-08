--------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")

--------------------------------------------------------------------------------------------------------
lia = lia or {
    util = {},
    gui = {},
    meta = {}
}

--------------------------------------------------------------------------------------------------------
include("config.lua")
include("loader.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------
local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()

cvars.AddChangeCallback("lia_cheapblur", function(name, old, new)
    useCheapBlur = (tonumber(new) or 0) > 0
end)

--------------------------------------------------------------------------------------------------------
CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

--------------------------------------------------------------------------------------------------------
timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")