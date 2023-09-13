----------------------------------------------------------------------------------------------
local MODULE = MODULE
----------------------------------------------------------------------------------------------
function MODULE:SetupInventorySearch(client, target)
    local function searcherCanAccess(inventory, action, context)
        if context.client == client then return true end
    end

    target:getChar():getInv():addAccessRule(searcherCanAccess)
    target.liaSearchAccessRule = searcherCanAccess
    target:getChar():getInv():sync(client)
end
----------------------------------------------------------------------------------------------
function MODULE:RemoveInventorySearchPermissions(client, target)
    local rule = target.liaSearchAccessRule
    if rule then
        target:getChar():getInv():removeAccessRule(rule)
    end
end
----------------------------------------------------------------------------------------------
function MODULE:searchPlayer(client, target)
    if IsValid(target:getNetVar("searcher")) or IsValid(client.liaSearchTarget) then
        client:notifyLocalized("This person is already being searched.")

        return false
    end

    if not target:getChar() or not target:getChar():getInv() then
        client:notifyLocalized("invalidPly")

        return false
    end

    self:SetupInventorySearch(client, target)
    netstream.Start(client, "searchPly", target, target:getChar():getInv():getID())
    client.liaSearchTarget = target
    target:setNetVar("searcher", client)

    return true
end
----------------------------------------------------------------------------------------------
function MODULE:CanPlayerInteractItem(client, action, item)
    if IsValid(client:getNetVar("searcher")) then return false end
end
----------------------------------------------------------------------------------------------
function MODULE:stopSearching(client)
    local target = client.liaSearchTarget
    if IsValid(target) and target:getNetVar("searcher") == client then
        MODULE:RemoveInventorySearchPermissions(client, target)
        target:setNetVar("searcher", nil)
        client.liaSearchTarget = nil
        netstream.Start(client, "searchExit")
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerLoadout(client)
    client:setNetVar("restricted")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerCanHearPlayersVoice(listener, speaker)
    if not (speaker:getChar() and listener:getChar()) then return false end

    return not speaker:IsGagged()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:OnPlayerUnRestricted(client)
    local searcher = client:getNetVar("searcher")
    if IsValid(searcher) then
        self:stopSearching(searcher)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerUse(client, entity)
    if not entity:IsPlayer() then return end
    if not client:getNetVar("restricted") and entity:getNetVar("restricted") then
        if not entity.liaBeingUnTied then
            entity.liaBeingUnTied = true
            entity:setAction("@beingUntied", 5)
            client:setAction("@unTying", 5)
            client:doStaredAction(
                entity,
                function()
                    entity:setRestricted(false)
                    entity.liaBeingUnTied = false
                    client:EmitSound("npc/roller/blade_in.wav")
                    entity:FreeTies()
                end,
                5,
                function()
                    entity.liaBeingUnTied = false
                    entity:setAction()
                    client:setAction()
                end
            )
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawn(ply)
    if not ply:getChar() then return end
    ply:FreeTies()
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerDeath(ply, cmd)
    if not ply:getNetVar("dragged", false) then
        return
    else
        if Dragging[ply] and IsValid(Dragging[ply]) then
            local dragger = Dragging[ply]
            local TargetPos = dragger:GetPos()
            cmd:ClearMovement()
            local myPos = ply:GetPos()
            local MoveVector = WorldToLocal(TargetPos, Angle(0, 0, 0), myPos, ply:GetAngles())
            MoveVector:Normalize()
            MoveVector:Mul(lia.config.DragMoveSpeed)
            cmd:RemoveKey(IN_JUMP)
            cmd:RemoveKey(IN_SPEED)
            cmd:RemoveKey(IN_DUCK)
            local dist2Sqr = (TargetPos.x - myPos.x) ^ 2 + (TargetPos.y - myPos.y) ^ 2
            if dist2Sqr > lia.config.MaxDistance then
                ply:getNetVar("dragged", false)

                return
            elseif dist2Sqr > lia.config.TargetRadius then
                cmd:SetForwardMove(MoveVector.x)
                cmd:SetSideMove(-MoveVector.y)
            end
        end
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:KeyPress(ply, key)
    if IsValid(ply) and key == IN_ATTACK and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == lia.config.DragSWEP and not ply:InVehicle() and not IsBeingDragged(ply) then
        local traceEnt = ply:GetEyeTrace().Entity
        if IsValid(traceEnt) and traceEnt:IsPlayer() and traceEnt:GetPos():DistToSqr(ply:GetPos()) <= lia.config.DraggingStartRange * lia.config.DraggingStartRange and traceEnt:getNetVar("restricted") and not traceEnt:InVehicle() then
            SetDrag(traceEnt, ply)
        end
    end
end
------------------------------------------------------------------------------------------------------------------------