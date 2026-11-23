net.Receive("AppearanceMenuClosed", function(_, client)
    lia.appearance.removeUser(client)
end)

net.Receive("AppearanceMenuSubmit", function(_, client)
    local target = net.ReadEntity()
    local modelChanged = net.ReadBool()
    local requestedModel = net.ReadString()
    local skin = net.ReadUInt(10)
    local bodygroups = net.ReadTable()
    if not IsValid(target) or not target:IsPlayer() then return end
    local character = target:getChar()
    if not character then return end

    local selfTarget = target == client
    if selfTarget then
        if not lia.appearance.canAccess(client) then
            client:notify("No Access")
            return
        end
    else
        local allowed = client:hasPrivilege("manageBodygroups") or client:hasPrivilege("changeBodygroups")
        if not allowed then
            client:notify("No Access")
            return
        end
        if modelChanged then return end
    end

    local model = target:GetModel()
    if modelChanged then
        local allowed, resolvedModel = lia.appearance.isWardrobeModelAllowed(character, requestedModel)
        if not allowed then
            client:notify("That model isn't allowed.")
            return
        end
        model = resolvedModel
    end

    local validatedBodygroups = lia.appearance.validateSelection(target, model, skin, bodygroups)
    if not validatedBodygroups then
        client:notify("Invalid appearance selection.")
        return
    end

    if modelChanged then
        character:setModel(model)
        target:SetModel(model)
        target:SetupHands()
    end

    character:setSkin(skin)
    character:setBodygroups(validatedBodygroups)
    target:SetSkin(skin)
    for index, value in pairs(validatedBodygroups) do
        target:SetBodygroup(index, value)
    end

    if selfTarget then
        target:notify("Your appearance has been updated.")
        lia.appearance.removeUser(target)
    else
        client:notify(string.format("You changed %s appearance.", target:Name() .. "'s"))
        target:notify(string.format("%s changed your appearance.", client:Name()))
    end

    net.Start("AppearanceMenuDismiss")
    net.Send(client)
end)
