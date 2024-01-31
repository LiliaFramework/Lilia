---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local function DrawWarning()
    if MODULE.Alpha < 230 then MODULE.Alpha = MODULE.Alpha + (FrameTime() * 200) end
    draw.RoundedBox(0, 0, (ScrH() / 2) - ScreenScale(60), ScrW(), ScreenScale(120), Color(0, 0, 0, MODULE.Alpha))
    draw.DrawText(MODULE.WarningHead, "AFKKicker120", ScrW() * 0.5, (ScrH() * 0.5) - ScreenScale(50), Color(255, 0, 0, MODULE.Alpha), TEXT_ALIGN_CENTER)
    draw.DrawText(MODULE.WarningSub .. "\nYou will be kicked in " .. math.floor(math.max(MODULE.KickTime - (CurTime() - MODULE.WarningStart), 0)) .. "s", "AFKKicker25", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, MODULE.Alpha), TEXT_ALIGN_CENTER)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:EnableWarning()
    self.Alpha = 0
    self.WarningStart = CurTime()
    surface.PlaySound("HL1/fvox/bell.wav")
    hook.Add("HUDPaint", "AFKWarning", DrawWarning)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:DisableWarning()
    self.Alpha = nil
    self.AlphaRising = nil
    hook.Remove("HUDPaint", "AFKWarning")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:LoadFonts()
    surface.CreateFont("AFKKicker25", {
        font = "Roboto",
        size = 25,
        weight = 400
    })

    surface.CreateFont("AFKKicker120", {
        font = "Roboto",
        size = 120,
        weight = 400
    })
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
