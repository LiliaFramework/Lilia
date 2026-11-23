lia.command.add("listbodygroups", {
    adminOnly = true,
    desc = "List the available bodygroups for a target player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local bodygroups = {}
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) > 1 then
                table.insert(bodygroups, {
                    group = i,
                    name = target:GetBodygroupName(i),
                    range = "0-" .. target:GetBodygroupCount(i) - 1
                })
            end
        end

        if #bodygroups > 0 then
            lia.util.createTableUI({
                title = string.format("Bodygroups for %s", target:Nick()),
                columns = {
                    {
                        name = "Group ID",
                        field = "group"
                    },
                    {
                        name = "Name",
                        field = "name"
                    },
                    {
                        name = "Range",
                        field = "range"
                    }
                },
                data = bodygroups,
            }, client)
        else
            client:notifyInfo(string.format("No bodygroups available for this model."))
        end
    end
})

lia.command.add("chareditbodygroups", {
    adminOnly = true,
    privilege = "changeBodygroups",
    desc = "Open the bodygroup editor for a player's character.",
    arguments = {
        {
            name = "Name",
            type = "player"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1] or "")
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not target:getChar() then
            client:notifyError(string.format("Player has no character loaded"))
            return
        end

        lia.appearance.openMenu(client, target, false)
    end
})

lia.command.add("charsetbodygroup", {
    adminOnly = true,
    desc = "Set a specific bodygroup on a player's model.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "bodygroupName",
            type = "string"
        },
        {
            name = "value",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local bodyGroup = arguments[2]
        local value = tonumber(arguments[3])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        local index = lia.util.resolveBodygroupIndex(target, bodyGroup)
        if not character or index == nil or index < 0 or index >= target:GetNumBodyGroups() then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        if value and (value ~= math.floor(value) or value < 0 or value >= target:GetBodygroupCount(index)) then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        if value and value < 1 then value = nil end
        local groups = lia.util.normalizeBodygroups(character.vars.bodygroups)
        groups[index] = value
        character:setBodygroups(groups)
        target:SetBodygroup(index, value or 0)
        client:notifySuccess(string.format("%s changed %s's bodygroup \"%s\" to %s.", client:Name(), target:Name(), bodyGroup, value or 0))
    end
})

lia.command.add("charsetskin", {
    adminOnly = true,
    desc = "Set a player's skin.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Skin",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Set Character Skin",
        ButtonText = "Set Character Skin",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local skin = tonumber(arguments[2])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        local skinCount = target:SkinCount() or 0
        if not character or not skin or skin ~= math.floor(skin) or skin < 0 or skinCount > 0 and skin >= skinCount or skinCount <= 0 and skin ~= 0 then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        character:setSkin(skin)
        target:SetSkin(skin)
        client:notifySuccess(string.format("%s changed %s's skin to %s.", client:Name(), target:Name(), skin))
    end
})

lia.command.add("viewBodygroups", {
    adminOnly = true,
    arguments = {
        {
            name = "target",
            type = "player"
        }
    },
    desc = "View and edit a player's bodygroups.",
    AdminStick = {
        Name = "View and edit a player's bodygroups.",
        ButtonText = "View Bodygroups",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1] or "")
        if not target or not IsValid(target) then
            client:notify(string.format("Target not found"))
            return
        end

        if not target:getChar() then
            client:notifyError(string.format("Player has no character loaded"))
            return
        end

        lia.appearance.openMenu(client, target, false)
    end
})
