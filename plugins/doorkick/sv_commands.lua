lia.command.add("doorkick", {
    syntax = "",
    onRun = function(client)
        local char = client:getChar()

        if char:getFaction() == FACTION_CITIZEN then
            client:notify("You are too weak to kick this door in!")

            return
        else
            if not client.isKickingDoor then
                local ent = client:GetEyeTraceNoCursor().Entity

                if IsValid(ent) and ent:isDoor() then
                    local dist = ent:GetPos():Distance(client:GetPos())

                    if dist > 60 and dist < 80 then
                        if not ent:getNetVar("faction") or ent:getNetVar("faction") ~= FACTION_STAFF then
                            client:Freeze(true)
                            client.isKickingDoor = true
                            net.Start("DoorKickView")
                            net.Send(client)

                            timer.Simple(0.5, function()
                                timer.Simple(0.9, function()
                                    if IsValid(client) then
                                        client:Freeze(false)
                                        client.isKickingDoor = false
                                    end
                                end)

                                if IsValid(ent) then
                                    ent:Fire("unlock")
                                    ent:Fire("open")
                                end
                            end)
                        else
                            client:notify("This door can not be kicked in!")
                        end
                    elseif dist < 60 then
                        client:notify("You are too close to kick the door down!")
                    elseif dist > 80 then
                        client:notify("You are too far to kick the door down!")
                    end
                else
                    client:notify("You are looking at an invalid door")
                end
            end
        end
    end
})