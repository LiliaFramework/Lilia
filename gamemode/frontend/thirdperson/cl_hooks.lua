--------------------------------------------------------------------------------------------------------
local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng
local clmp = math.Clamp
local diff, fm, sm
crouchFactor = 0
--------------------------------------------------------------------------------------------------------
hook.Add(
    "SetupQuickMenu",
    "ThirdPersonSetupQuickMenu",
    function(menu)
        if lia.config.ThirdPersonEnabled then
            menu:addCheck(
                L"thirdpersonToggle",
                function(panel, state)
                    if state then
                        RunConsoleCommand("lia_tp_enabled", "1")
                    else
                        RunConsoleCommand("lia_tp_enabled", "0")
                    end
                end, CreateClientConVar("lia_tp_enabled", "0", true):GetBool()
            )

            menu:addCheck(
                L"thirdpersonClassic",
                function(panel, state)
                    if state then
                        RunConsoleCommand("lia_tp_classic", "1")
                    else
                        RunConsoleCommand("lia_tp_classic", "0")
                    end
                end, CreateClientConVar("lia_tp_classic", "0", true):GetBool()
            )

            menu:addButton(
                L"thirdpersonConfig",
                function()
                    if lia.gui.tpconfig and lia.gui.tpconfig:IsVisible() then
                        lia.gui.tpconfig:Close()
                        lia.gui.tpconfig = nil
                    end

                    lia.gui.tpconfig = vgui.Create("liaTPConfig")
                end
            )

            menu:addSpacer()
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "CalcView",
    "ThirdPersonCalcView",
    function(client, origin, angles, fov)
        ft = FrameTime()
        if client:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
            if (client:OnGround() and client:KeyDown(IN_DUCK)) or client:Crouching() then
                crouchFactor = Lerp(ft * 5, crouchFactor, 1)
            else
                crouchFactor = Lerp(ft * 5, crouchFactor, 0)
            end

            curAng = owner.camAng or Angle(0, 0, 0)
            view = {}
            traceData = {}
            traceData.start = client:GetPos() + client:GetViewOffset() + curAng:Up() * clmp(CreateClientConVar("lia_tp_vertical", 10, true):GetInt(), 0, 30) + curAng:Right() * clmp(CreateClientConVar("lia_tp_horizontal", 0, true):GetInt(), -30, 30) - client:GetViewOffsetDucked() * .5 * crouchFactor
            traceData.endpos = traceData.start - curAng:Forward() * clmp(CreateClientConVar("lia_tp_distance", 50, true):GetInt(), 0, 100)
            traceData.filter = client
            view.origin = util.TraceLine(traceData).HitPos
            aimOrigin = view.origin
            view.angles = curAng + client:GetViewPunchAngles()
            traceData2 = {}
            traceData2.start = aimOrigin
            traceData2.endpos = aimOrigin + curAng:Forward() * 65535
            traceData2.filter = client
            if CreateClientConVar("lia_tp_classic", "0", true):GetBool() or (owner.isWepRaised and owner:isWepRaised() or (owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and owner:GetVelocity():Length() >= 10)) then
                client:SetEyeAngles((util.TraceLine(traceData2).HitPos - client:GetShootPos()):Angle())
            end

            return view
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "CreateMove",
    "ThirdPersonCreateMove",
    function(cmd)
        owner = LocalPlayer()
        if owner:CanOverrideView() and owner:GetMoveType() ~= MOVETYPE_NOCLIP and LocalPlayer():GetViewEntity() == LocalPlayer() then
            fm = cmd:GetForwardMove()
            sm = cmd:GetSideMove()
            diff = (owner:EyeAngles() - (owner.camAng or Angle(0, 0, 0)))[2] or 0
            diff = diff / 90
            cmd:SetForwardMove(fm + sm * diff)
            cmd:SetSideMove(sm + fm * diff)

            return false
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "InputMouseApply",
    "ThirdPersonInputMouseApply",
    function(cmd, x, y, ang)
        owner = LocalPlayer()
        if not owner.camAng then
            owner.camAng = Angle(0, 0, 0)
        end

        if owner:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
            owner.camAng.p = clmp(math.NormalizeAngle(owner.camAng.p + y / 50), -85, 85)
            owner.camAng.y = math.NormalizeAngle(owner.camAng.y - x / 50)

            return true
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "ShouldDrawLocalPlayer",
    "ThirdPersonShouldDrawLocalPlayer",
    function()
        if LocalPlayer():GetViewEntity() == LocalPlayer() and not IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():CanOverrideView() then return true end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "PlayerButtonDown",
    "ThirdPersonPlayerButtonDown",
    function(ply, button)
        if button == KEY_F4 and IsFirstTimePredicted() then
            local toggle = GetConVar("lia_tp_enabled")
            if toggle:GetInt() == 1 then
                toggle:SetInt(0)
            else
                toggle:SetInt(1)
            end
        end
    end
)
--------------------------------------------------------------------------------------------------------