DeriveGamemode("sandbox")

lia = lia or {
    util = {},
    gui = {},
    meta = {}
}

include("core/sh_util.lua")
include("shared.lua")

CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

-- Disable the opening menu hint system timer
timer.Remove("HintSystem_OpeningMenu")
-- Disable the first annoyance hint system timer
timer.Remove("HintSystem_Annoy1")
-- Disable the second annoyance hint system timer
timer.Remove("HintSystem_Annoy2")