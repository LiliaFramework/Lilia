--[[
    Hooks:
        ShouldAllowSit(client, position, pitch, entity)
    Purpose:
        Allows code to approve or deny sitting at a traced position and optionally choose the seated facing direction.
    Category:
        Sitting
    Parameters:
        client (Player)
            The player attempting to sit.
        position (Vector)
            The traced world position where the player is attempting to sit.
        pitch (number)
            The pitch of the traced surface in degrees.
        entity (Entity)
            The world or entity under the traced position.
    Example Usage:
        ```lua
        hook.Add("ShouldAllowSit", "liaExampleShouldAllowSit", function(client, position, pitch, entity)
            if IsValid(entity) and entity:GetClass() == "prop_physics" then
                return true, 90
            end
        end)
        ```
    Returns:
        boolean|nil, number|nil
            Return true or false to override the normal sit check. The optional second value is the seated yaw in degrees.
    Realm:
        Shared
]]
--[[
    Folder: Developer - Libraries
    File: lia.sit.md
]]
--[[
    Sit

    Adds player sitting with position validation, safe facing directions, and invisible seats.
]]
--[[
    Overview:
        The sit library adds player sitting under `lia.sit`. It validates surface positions and facing rotations, finds safe seating directions, supports the `ShouldAllowSit` hook, and creates invisible vehicle seats that can be attached to world entities.
]]
lia.sit = lia.sit or {}
--[[
    Purpose:
        Checks whether a seated player can face a specific yaw without intersecting nearby geometry.
    Parameters:
        position (Vector)
            The world position where the player will sit.
        surfaceAngle (Angle)
            The angle of the surface under the sitting position.
        rotation (number)
            The proposed seated yaw in degrees.
    Returns:
        boolean
            Whether the proposed seated rotation has enough clearance.
    Realm:
        Shared
]]
function lia.sit.isValidSittingRotation(position, surfaceAngle, rotation)
    if not isnumber(rotation) then return false end
    local rad = math.rad(rotation)
    local dir = Vector(math.cos(rad), math.sin(rad), 0)
    local players = player.GetAll()
    local verticalTrace = util.TraceLine({
        start = position - dir * 19.5 + surfaceAngle:Forward() * 5,
        endpos = position - dir * 19.5 + surfaceAngle:Forward() * -160,
        filter = players
    })

    local horizontalTrace = util.TraceLine({
        start = position + Vector(0, 0, 5),
        endpos = position + Vector(0, 0, 5) - dir * 1600,
        filter = players
    })
    return horizontalTrace.StartPos:Distance(horizontalTrace.HitPos) > 20 and verticalTrace.StartPos:Distance(verticalTrace.HitPos) > 14
end

lia.sit.checkValidRotation = lia.sit.isValidSittingRotation
if SERVER then
    lia.sit.cooldown = lia.sit.cooldown or {}
    local pitchOffset = Angle(270, 0, 0)
    local optimalOffset = Vector(0, 0, 5)
    local optimalOffsetHeight = Vector(0, 0, -20)
    concommand.Add("sit", function(ply)
        local curTime = CurTime()
        local steamID = ply:SteamID64()
        if not lia.sit.cooldown[steamID] then lia.sit.cooldown[steamID] = 0 end
        if lia.sit.cooldown[steamID] > curTime then return end
        lia.sit.cooldown[steamID] = curTime + 0.5
        local eyeTrace = ply:GetEyeTrace()
        local pos = eyeTrace.HitPos
        local ent = eyeTrace.Entity
        local pitch = (eyeTrace.HitNormal:Angle() - pitchOffset).pitch
        local canSit, optimalRotation = lia.sit.canPlayerSitAt(ply, pos, pitch, ent)
        if not canSit then return end
        lia.sit.placePlayerInSeat(ply, pos, ent:IsWorld() and NULL or ent, optimalRotation, pitch)
    end)

    --[[
        Purpose:
            Finds the safest available yaw for placing a sitting player at a position.
        Parameters:
            position (Vector)
                The world position where the player will sit.
        Returns:
            number|false
                The recommended seated yaw in degrees, or false when no valid direction is available.
        Realm:
            Server
    ]]
    function lia.sit.findBestSittingRotation(position)
        local allPly = player.GetAll()
        local furthest
        for i = 0, 360, 45 do
            local rad = math.rad(i)
            local dir = Vector(math.cos(rad), math.sin(rad), 0)
            local startPos = position + dir * 15 + optimalOffset
            local trace = util.QuickTrace(startPos, optimalOffsetHeight, allPly)
            if trace.Hit then continue end
            local traceToStart = util.QuickTrace(startPos + (-optimalOffset * 1.2), dir * -15, allPly)
            traceToStart.rotation = i
            if not furthest then
                furthest = traceToStart
                continue
            end

            if furthest.HitPos:Distance(furthest.StartPos) < traceToStart.HitPos:Distance(traceToStart.StartPos) then furthest = traceToStart end
        end

        if not furthest then return false end
        return furthest.rotation
    end

    --[[
        Purpose:
            Checks whether a player can sit at a position and returns a suitable seated yaw.
        Parameters:
            player (Player)
                The player attempting to sit.
            position (Vector)
                The world position where the player wants to sit.
            pitch (number)
                The pitch of the surface in degrees.
            entity (Entity)
                The world or entity under the position.
        Returns:
            boolean, number|nil
                Whether sitting is allowed and, when allowed, the recommended seated yaw in degrees.
        Realm:
            Server
    ]]
    function lia.sit.canPlayerSitAt(player, position, pitch, entity)
        if player:GetPos():DistToSqr(position) > 10000 then return false end
        if entity:IsPlayer() then return false end
        if pitch > 10 then return false end
        if pitch < -10 then return false end
        local canSit, sitRotation = hook.Run("ShouldAllowSit", player, position, pitch, entity)
        if not (canSit == nil) then return canSit, sitRotation or lia.sit.findBestSittingRotation(position) or 0 end
        local rotation = lia.sit.findBestSittingRotation(position)
        if not rotation then return false end
        return true, rotation
    end

    --[[
        Purpose:
            Creates an invisible seat and places a player in it at the requested position and rotation.
        Parameters:
            player (Player)
                The player to place in the seat.
            position (Vector)
                The world position where the player will sit.
            entity (Entity)
                An optional entity to parent the seat to, or NULL for a world position.
            rotation (number)
                The seated yaw in degrees.
            pitch (number)
                The seated pitch in degrees.
            manualFacing (boolean)
                Whether the supplied rotation is a manually selected facing direction.
        Realm:
            Server
    ]]
    function lia.sit.placePlayerInSeat(player, position, entity, rotation, pitch, manualFacing)
        local chair = ents.Create("prop_vehicle_prisoner_pod")
        chair.liaSit = true
        if IsValid(entity) and not entity:IsWorld() then
            chair:SetParent(entity)
            player:DropObject()
        end

        chair:SetModel("models/nova/airboat_seat.mdl")
        chair:SetPos(position - optimalOffset)
        local chairYaw = manualFacing and rotation + 90 or rotation - 90
        local ang = Angle(0, chairYaw, 0)
        ang:RotateAroundAxis(ang:Forward(), pitch)
        chair:SetAngles(ang)
        chair:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
        chair:Spawn()
        chair:Activate()
        chair:SetVehicleClass("Seat_Airboat")
        chair:SetNotSolid(true)
        entity.liaSitChair = chair
        chair:CallOnRemove("UnTie", function(entChair)
            local parent = entChair:GetParent()
            if IsValid(parent) then parent.liaSitChair = nil end
        end)

        local phys = chair:GetPhysicsObject()
        if IsValid(phys) then
            phys:Sleep()
            phys:EnableGravity(false)
            phys:EnableMotion(false)
            phys:EnableCollisions(false)
            phys:SetMass(1)
        end

        chair:SetColor(Color(0, 0, 0, 0))
        chair:SetRenderMode(RENDERMODE_TRANSALPHA)
        chair:DrawShadow(false)
        chair.PhysgunDisabled = true
        chair.m_tblToolsAllowed = {}
        chair.customCheck = function() return false end
        chair:SetCollisionGroup(COLLISION_GROUP_WORLD)
        player:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        chair.SIMPIdealLeaveSpace = player:GetPos()
        player:EnterVehicle(chair)
        if manualFacing then
            player:SetEyeAngles(Angle(0, rotation, 0))
        else
            player:SetEyeAngles(Angle(0, 90, 0))
        end
    end

    lia.sit.optimalRotation = lia.sit.findBestSittingRotation
    lia.sit.canSitHere = lia.sit.canPlayerSitAt
    lia.sit.sit = lia.sit.placePlayerInSeat
    net.Receive("liaSitSitFacing", function(_, ply)
        local curTime = CurTime()
        local steamID = ply:SteamID64()
        if not lia.sit.cooldown[steamID] then lia.sit.cooldown[steamID] = 0 end
        if lia.sit.cooldown[steamID] > curTime then return end
        lia.sit.cooldown[steamID] = curTime + 0.5
        local wantedRotation = net.ReadFloat()
        local traceDirection = net.ReadVector()
        if wantedRotation ~= wantedRotation then return end
        if math.abs(wantedRotation) > 100000 then return end
        if traceDirection:LengthSqr() <= 0 then return end
        traceDirection:Normalize()
        local traceStart = ply:EyePos()
        local eyeTrace = util.TraceLine({
            start = traceStart,
            endpos = traceStart + traceDirection * 12000,
            filter = player.GetAll()
        })

        if not eyeTrace.Hit then return end
        local pos = eyeTrace.HitPos
        local ent = eyeTrace.Entity
        local pitch = (eyeTrace.HitNormal:Angle() - pitchOffset).pitch
        if ply:GetPos():DistToSqr(pos) > 10000 then return end
        if IsValid(ent) and ent:IsPlayer() then return end
        if pitch > 10 then return end
        if pitch < -10 then return end
        local canSit, sitRotation = hook.Run("ShouldAllowSit", ply, pos, pitch, ent)
        if canSit == false then return end
        local rotation = math.NormalizeAngle(wantedRotation)
        local manualFacing = true
        if isnumber(sitRotation) then
            rotation = sitRotation
            manualFacing = false
        elseif not lia.sit.isValidSittingRotation(pos, eyeTrace.HitNormal:Angle(), rotation) then
            return
        end

        lia.sit.placePlayerInSeat(ply, pos, IsValid(ent) and not ent:IsWorld() and ent or NULL, rotation, pitch, manualFacing)
    end)

    hook.Add("PlayerLeaveVehicle", "lia.sit.remove", function(ply, chair)
        if not IsValid(chair) then return end
        if not chair.liaSit then return end
        local idealLeaveSpace = chair.SIMPIdealLeaveSpace
        chair:Remove()
        if idealLeaveSpace:DistToSqr(chair:GetPos()) < 50000 then ply:SetPos(idealLeaveSpace) end
    end)

    hook.Add("PlayerDisconnected", "lia.sit.remove", function(ply)
        local chair = ply:GetVehicle()
        if not IsValid(chair) then return end
        if not chair.liaSit then return end
        chair:Remove()
    end)

    hook.Add("CanUndo", "lia.sit.antiAbuse", function(ply, tUndo)
        if isstring(tUndo.Name) and string.lower(tUndo.Name):find("precision") then
            local fn = tUndo.Functions[1]
            local data = fn and fn[2]
            local ent = data and data[1]
            if IsValid(ent) and IsValid(ent.liaSitChair) then return false end
        end
    end)

    hook.Add("CanTool", "lia.sit.antiAbuse", function(ply, tr, toolname, tool, button)
        local trEnt = tr.Entity
        if IsValid(trEnt) and IsValid(trEnt.liaSitChair) then return false end
    end)

    hook.Add("PhysgunPickup", "lia.sit.antiAbuse", function(ply, trEnt) if IsValid(trEnt) and IsValid(trEnt.liaSitChair) then return false end end)
else
    local arrow = Material("widgets/arrow.png")
    local white = Color(255, 255, 255, 255)
    local red = Color(255, 0, 0, 255)
    local drawScale = 0.1
    local traceDistance = 20
    local traceScaled = traceDistance / drawScale
    local currentSit
    local function CanUseSit(ply)
        if not IsValid(ply) then return false end
        if IsValid(ply:GetVehicle()) then return false end
        return true
    end

    local function GetTriggerButton()
        local buttons = {KEY_LALT, KEY_E}
        return buttons[#buttons]
    end

    local function AreModifierButtonsDown()
        local buttons = {KEY_LALT, KEY_E}
        if #buttons < 2 then return true end
        for i = 1, #buttons - 1 do
            if not input.IsButtonDown(buttons[i]) then return false end
        end
        return true
    end

    local function RemovePreview()
        hook.Remove("PostDrawOpaqueRenderables", "lia.sit.PostDrawOpaqueRenderables")
    end

    local function StartSit(trace)
        local wantedRotation
        local start = CurTime()
        local ply = LocalPlayer()
        hook.Add("PostDrawOpaqueRenderables", "lia.sit.PostDrawOpaqueRenderables", function()
            if CurTime() - start <= 0.25 then return end
            if not CanUseSit(ply) then
                wantedRotation = nil
                RemovePreview()
                return
            end

            local vec = util.IntersectRayWithPlane(ply:EyePos(), ply:EyeAngles():Forward(), trace.HitPos, Vector(0, 0, 1))
            if not vec or vec:DistToSqr(trace.HitPos) < 4 then
                local fallbackDirection = Angle(0, ply:EyeAngles().y, 0):Forward()
                vec = trace.HitPos + fallbackDirection * traceDistance
            end

            local posOnPlane = WorldToLocal(vec, Angle(0, 90, 0), trace.HitPos, Angle(0, 0, 0))
            local testVec = posOnPlane:GetNormal() * traceScaled
            local currentAng = (trace.HitPos - vec):Angle()
            local goodSit = lia.sit.isValidSittingRotation(trace.HitPos, trace.HitNormal:Angle(), currentAng.y)
            if goodSit then
                wantedRotation = currentAng.y
            else
                wantedRotation = nil
            end

            cam.Start3D2D(trace.HitPos + Vector(0, 0, 1), Angle(0, 0, 0), drawScale)
            surface.SetDrawColor(goodSit and white or red)
            surface.SetMaterial(arrow)
            surface.DrawTexturedRectRotated(testVec.x * 0.5, testVec.y * -0.5, 2 / drawScale, traceScaled, currentAng.y + 90)
            cam.End3D2D()
        end)
        return function()
            RemovePreview()
            if not CanUseSit(ply) then return end
            if CurTime() - start < 0.25 then
                RunConsoleCommand("sit")
                return
            end

            if not wantedRotation then return end
            local traceDirection = trace.HitPos - trace.StartPos
            if traceDirection:LengthSqr() <= 0 then return end
            traceDirection:Normalize()
            net.Start("liaSitSitFacing")
            net.WriteFloat(wantedRotation)
            net.WriteVector(traceDirection)
            net.SendToServer()
        end
    end

    hook.Add("PlayerButtonDown", "lia.sit.keyPress", function(ply, button)
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
        if ply ~= LocalPlayer() then return end
        if button ~= GetTriggerButton() then return end
        if currentSit then return end
        if not CanUseSit(ply) then return end
        if not AreModifierButtonsDown() then return end
        local trace = ply:GetEyeTrace()
        if not trace.Hit then return end
        currentSit = StartSit(table.Copy(trace))
    end)

    hook.Add("PlayerButtonUp", "lia.sit.keyRelease", function(ply, button)
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
        if ply ~= LocalPlayer() then return end
        if button ~= GetTriggerButton() then return end
        if not currentSit then return end
        local finishSit = currentSit
        currentSit = nil
        finishSit()
    end)
end
