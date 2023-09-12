----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lia.config.PlayerInteractionOptions = {
    ["Allow This Player To Recognize You"] = {
        Callback = function(client, target)
            local id = client:getChar():getID()
            if SERVER then
                if target:GetPos():DistToSqr(client:GetPos()) > 100000 then return end
                if target:getChar():recognize(id) then
                    netstream.Start(client, "rgnDone")
                    hook.Run("OnCharRecognized", client, id)
                    client:notifyLocalized("recognized")
                else
                    client:notifyLocalized("already_recognized")
                end
            end
        end,
        CanSee = function(client, target) return GM:IsValidTarget(target) and not client:getChar():doesRecognize(target:getChar()) end,
    },
    ["Give Money"] = {
        Callback = function(client, target)
            local function HandleInput(number)
                local amount = math.floor(number or 0)
                if not amount or not isnumber(amount) or amount <= 0 then
                    client:ChatPrint("Invalid Amount!")

                    return
                elseif not client:getChar():hasMoney(amount) then
                    client:ChatPrint("You lack the funds to use this!")

                    return
                end

                if SERVER then
                    target:getChar():giveMoney(amount)
                    client:getChar():takeMoney(amount)
                end

                target:notifyLocalized("moneyTaken", lia.currency.get(amount))
                client:notifyLocalized("moneyGiven", lia.currency.get(amount))
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
            end

            if CLIENT then
                Derma_StringRequest(
                    "Input a Monetary Value",
                    "Input a money value to give",
                    "",
                    function(text)
                        local number = tonumber(text)
                        HandleInput(number)
                    end
                )
            end
        end,
        CanSee = function(client, target) return GM:IsValidTarget(target) and client:getChar():getMoney() > 0 end
    },
    ["Tie Player"] = {
        Callback = function(client, target)
            if SERVER then
                client:getChar():getInv():getFirstItemOfType("tie"):remove()
                client:EmitSound("physics/plastic/plastic_barrel_strain" .. math.random(1, 3) .. ".wav")
            end

            if target:Team() == FACTION_STAFF then
                target:notify("You were just attempted to be restrained by " .. client:Name() .. ".")
                client:notify("You can't tie a staff member!")

                return
            end

            client:setAction("@tying", 3)
            client:doStaredAction(
                target,
                function()
                    if SERVER then
                        target:setRestricted(true)
                        target:setNetVar("tying")
                        client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
                    end
                end,
                3,
                function()
                    client:setAction()
                    target:setAction()
                    if SERVER then
                        target:setNetVar("tying")
                    end
                end
            )

            if SERVER then
                target:setNetVar("tying", true)
                target:setAction("@beingTied", 3)
            end
        end,
        CanSee = function(client, target) return GM:IsValidTarget(target) and client:ConditionsMetForTying(target) end
    },
    ["Open Detailed Description"] = {
        Callback = function(client, target)
            if SERVER then
                net.Start("OpenDetailedDescriptions")
                net.WriteEntity(target)
                net.WriteString(target:getChar():getData("textDetDescData", nil) or "No detailed description found.")
                net.WriteString(target:getChar():getData("textDetDescDataURL", nil) or "No detailed description found.")
                net.Send(client)
            end
        end,
        CanSee = function(client, target) return GM:IsValidTarget(target) end
    },
    ["Set Detailed Description"] = {
        Callback = function(client, target)
            if SERVER then
                net.Start("SetDetailedDescriptions")
                net.WriteString(target:steamName())
                net.Send(client)
            end
        end,
        CanSee = function(client, target) return GM:IsValidTarget(target) end
    },
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------