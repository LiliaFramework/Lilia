DeriveGamemode("sandbox")
lia = lia or {
    util = {},
    gui = {},
    meta = {}
}

nut = lia or {
    util = {},
    gui = {},
    meta = {}
}

include("core/sh_util.lua")
include("shared.lua")

CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")

function GM:HUDPaint()
    if BRANCH ~= "x86-64" then draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
end