--------------------------------------------------------------------------------------------------------
ANIM = {}
ANIM.runAnim = nil
ANIM.running = false
ANIM.curAlpha = 0
ANIM.overlay = ANIM.overlay or nil
ANIM.anims = {}
--------------------------------------------------------------------------------------------------------
local lerpEnd = CurTime()
local lerpStart = CurTime()
local fadeStart = CurTime()
local fadeEnd = CurTime()
local anim
local fadeTime
local song
local animCallback
local pointID = 0
local curPoint
--------------------------------------------------------------------------------------------------------
function ANIM:CreateDermaOverlay()
    if self.overlay and IsValid(self.overlay) then return end
    self.overlay = vgui.Create("CinematicOverlay")
    self.overlay:SetAnimSettings(anim.settings)
end
--------------------------------------------------------------------------------------------------------
function ANIM:ClearDerma()
    if self.overlay and IsValid(self.overlay) then
        self.overlay:Remove()
    end
end
--------------------------------------------------------------------------------------------------------
local qa = {}
qa.run = false
--------------------------------------------------------------------------------------------------------
function qa:Think()
    if not self.run then return end

    if CurTime() >= self.start + self.time then
        return self.pos2, self.ang2
    else
        local dt = math.TimeFraction(self.start, self.start + self.time, CurTime())
        local posLerp = LerpVector(dt, self.pos1, self.pos2)
        local angLerp = LerpAngle(dt, self.ang1, self.ang2)

        return posLerp, angLerp
    end
end
--------------------------------------------------------------------------------------------------------
function qa:Start()
    self.start = CurTime()
    self.run = true
end
--------------------------------------------------------------------------------------------------------
function qa:Init(time, pos1, ang1, pos2, ang2)
    local nqa = table.Copy(qa)
    nqa.time = time
    nqa.pos1 = pos1
    nqa.ang1 = ang1
    nqa.pos2 = pos2
    nqa.ang2 = ang2

    return nqa
end
--------------------------------------------------------------------------------------------------------
function ANIM:CreateQuickAnim(time, pos1, ang1, pos2, ang2)
    return qa:Init(time, pos1, ang1, pos2, ang2)
end
--------------------------------------------------------------------------------------------------------
hook.Add("RenderScreenspaceEffects", "drawTransitions", function()
    if not ANIM.running then return end
    surface.SetDrawColor(0, 0, 0, ANIM.curAlpha or 0)
    surface.DrawRect(0, 0, ScrW(), ScrH())
end)
--------------------------------------------------------------------------------------------------------
hook.Add("CalcView", "AnimationRun", function(ply, pos, angles, fov)
    if not ANIM.running then return end
    fadeTime = anim.settings.fadeTime

    if curPoint and lerpEnd >= CurTime() then
        --Getting the vectors and angles of the nodes
        local dt = math.TimeFraction(lerpStart, lerpEnd, CurTime())
        local fromPos, fromAng = strPosAngConv(curPoint.from)
        local toPos, toAng = strPosAngConv(curPoint.to)
        --Lerping from point A to B (same with angle)
        local vec = LerpVector(dt, fromPos, toPos)
        local ang = LerpAngle(dt, fromAng, toAng)
        --Fading Calculation thing
        local beforeFadeOut = (lerpEnd - CurTime()) <= fadeTime / 2

        --Checking if it is time to fadeout
        if beforeFadeOut and fadeEnd ~= lerpEnd then
            fadeStart = CurTime()
            fadeEnd = lerpEnd
        elseif fadeEnd == lerpEnd then
            --While fading out
            local fdt = math.TimeFraction(fadeStart, fadeEnd, CurTime())
            local alpha = Lerp(fdt, 0, 255)
            ANIM.curAlpha = alpha
        elseif not beforeFadeOut then
            --Before fadingout (fadein)
            local fdt = math.TimeFraction(fadeStart, fadeEnd, CurTime())
            local alpha = Lerp(fdt, 255, 0)
            ANIM.curAlpha = alpha
        end

        --Building viewport table
        local view = {}
        view.origin = vec
        view.angles = ang
        view.fov = fov
        view.drawviewer = true

        return view
    else
        pointID = pointID + 1

        if anim.points[pointID] == nil then
            if anim.settings.loopAnim then
                ANIM:Run(ANIM.runAnim, true)

                return
            end

            ANIM:Stop()

            return nil
        end

        curPoint = anim.points[pointID]
        local time = curPoint.time or anim.settings.baseTime
        lerpEnd = CurTime() + time --Setting times for the lerp
        lerpStart = CurTime()

        --Send text to derma
        if ANIM.overlay and IsValid(ANIM.overlay) then
            if curPoint.text then
                local overlay = ANIM.overlay
                overlay:DisplayText(curPoint.text, curPoint.time or anim.settings.baseTime, anim.settings.fadeTime / 2)
            else
                ANIM.overlay:HideText()
            end
        end

        --Setup the fade timing vars for fadein
        ANIM.curAlpha = 255
        fadeStart = lerpStart
        fadeEnd = lerpStart + fadeTime / 2
        --Some helping thing
        print("Scene " .. pointID .. "/" .. table.Count(anim.points))
    end
end)
--------------------------------------------------------------------------------------------------------
--Library to control the animation
function ANIM:Run(animName, restart, callback)
    if not animName then
        Error("No animation name provided")

        return
    end

    if not self.anims[animName] then
        Error("No animation called '" .. animName .. "'")

        return
    end

    --Resetting & setting vars
    curPoint = nil
    pointID = 0
    anim = self.anims[animName]

    --Checking if the animation fits the current map
    if anim.settings.map then
        local map = game.GetMap()

        if anim.settings.map ~= map then
            MsgC(Color(255, 0, 0), "[ANIM] ", color_white, "Animation '" .. animName .. "' can't run on map '" .. map .. "'\n")

            return
        end
    end

    --Telling the game we're about to run an animation
    self.runAnim = animName
    self.running = true

    if callback and isfunction(callback) then
        animCallback = callback
    end

    --Don't set new variables for nothing if restarted
    if not restart then
        --Getting 'from' points
        local duration = 0
        local PVSPoints = {}

        for k, v in pairs(anim.points) do
            local time = v.time or anim.settings.baseTime
            duration = duration + time
            local pos, _ = strPosAngConv(v.from)
            PVSPoints[#PVSPoints + 1] = pos
        end

        netstream.Start("AddPosToPVS", PVSPoints)

        --Start overlay if applicable
        if anim.settings.showSkipButton then
            self:CreateDermaOverlay()
        end

        --Creating song if necessary
        if anim.music and anim.music.path and LocalPlayer() then
            print("SONG START", LocalPlayer(), ply)
            song = CreateSound(LocalPlayer(), anim.music.path)
            song:Play()
            song:ChangeVolume(0.5)
        end

        return duration
    end
end
--------------------------------------------------------------------------------------------------------
function ANIM:Stop(smooth)
    local function resetVals(obj)
        obj.running = false
        obj.runAnim = nil
        obj:ClearDerma()
    end

    if smooth then
        self.overlay:Fade(function()
            resetVals(self)
        end)
    else
        resetVals(self)
    end

    if animCallback then
        animCallback()
    end

    --Removing PVS points
    netstream.Start("ClearPVS")

    --Stoping music
    if song and song:IsPlaying() then
        local fraction = 1
        local start, finish = RealTime(), RealTime() + 8

        timer.Create("liaMusicFader", 0.1, 0, function()
            if song then
                fraction = 1 - math.TimeFraction(start, finish, RealTime())
                song:ChangeVolume(fraction * 0.5)

                if fraction <= 0 then
                    song:Stop()
                    song = nil
                    timer.Remove("liaMusicFader")
                end
            else
                timer.Remove("liaMusicFader")
            end
        end)
    end
end
--------------------------------------------------------------------------------------------------------
function ANIM:QuickAnim(time, pos1, pos2, ang1, ang2)
    if not self.q then
        self.q = {}
        self.q.start = CurTime()

        if type(pos1) == "string" and type(pos2) == "string" then
            self.q.pos1, self.q.ang1 = strPosAngConv(pos1)
            self.q.pos2, self.q.ang2 = strPosAngConv(pos2)
        else
            self.q.pos1, self.q.pos2 = pos1, pos2
            self.q.ang1, self.q.ang2 = ang1, ang2
        end
    end

    --Runnin anim
    if self.q then
        if CurTime() >= self.q.start + time then
            local pos2, ang2 = self.q.pos2, self.q.ang2
            self.q = nil

            return false, pos2, ang2
        end

        local dt = math.TimeFraction(self.q.start, self.q.start + time, CurTime())
        local v = LerpVector(dt, self.q.pos1, self.q.pos2)
        local a = LerpAngle(dt, self.q.ang1, self.q.ang2)

        return v, a, q
    end
end
--------------------------------------------------------------------------------------------------------
function ANIM:Add(animTable)
    if not animTable.settings then
        Error("Unable to find the 'settings' table in the animation table")

        return
    end

    local name = animTable.settings.animName
    self.anims[name] = animTable
    MsgC(Color(0, 255, 0), "[ANIM] ", color_white, "Added animation " .. name .. "\n")
end
--------------------------------------------------------------------------------------------------------
concommand.Add("forceStartAnimation", function(ply, cmd, args)
    ANIM:Run(args[1])
end)
--------------------------------------------------------------------------------------------------------
concommand.Add("forceStopAnimation", function()
    ANIM:Stop()
end)
--------------------------------------------------------------------------------------------------------
cprint("Loaded Animation Library")
--------------------------------------------------------------------------------------------------------