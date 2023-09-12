------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "gagplayer",
    {
        adminOnly = false,
        privilege = "Basic User Permissions",
        onRun = function(client, arguments)
            local tr = util.TraceLine(util.GetPlayerTrace(client))
            local target = tr.Entity
            if not client:ConditionsMetForTyingExtras(target) then
                client:notify("Can't (Un)Gag This Player!!")

                return
            else
                if target:IsGagged() then
                    target:ToggleGagged()
                    client:notify("Ungagged Player!")
                else
                    target:ToggleGagged()
                    client:notify("Gagged Player!")
                end
            end
        end
    }
)

------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "blindplayer",
    {
        adminOnly = false,
        privilege = "Basic User Permissions",
        onRun = function(client, arguments)
            local tr = util.TraceLine(util.GetPlayerTrace(client))
            local target = tr.Entity
            if not client:ConditionsMetForTyingExtras(target) then
                client:notify("Can't (Un)Blind This Player!!")

                return
            else
                if target:IsBlinded() then
                    target:ToggleBlinded()
                    client:notify("Unblinded Player!")
                else
                    target:ToggleBlinded()
                    client:notify("Blinded Player!")
                end
            end
        end
    }
)

------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "dragplayer",
    {
        adminOnly = false,
        privilege = "Basic User Permissions",
        onRun = function(client, arguments)
            local tr = util.TraceLine(util.GetPlayerTrace(client))
            local target = tr.Entity
            if not client:ConditionsMetForTyingExtras(target) then
                client:notify("Can't (Un)Drag This Player!!")

                return
            else
                if target:IsDragged() then
                    client:notify("Stopped Dragging Player!")
                    SetDrag(nil, client)
                    SetDrag(target, nil)
                    target:setNetVar("dragged", false)
                else
                    SetDrag(target, client)
                    client:notify("Started Dragging Player!")
                    target:setNetVar("dragged", true)
                end
            end
        end
    }
)
------------------------------------------------------------------------------------------------------------------------