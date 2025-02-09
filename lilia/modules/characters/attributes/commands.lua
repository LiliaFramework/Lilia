lia.command.add("charsetattrib", {
    superAdminOnly = true,
    syntax = "[string charname] [string attribname] [number level]",
    privilege = "Manage Attributes",
    AdminStick = {
        Name = L("setAttributes"),
        Category = L("characterManagement"),
        SubCategory = L("attributes"),
        Icon = "icon16/wrench.png",
        ExtraFields = {
            ["attribute"] = function()
                local attributes = {}
                for _, v in pairs(lia.attribs.list) do
                    table.insert(attributes, L(v.name))
                end
                return attributes, "combo"
            end,
            ["value"] = "text",
        }
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local attribName = arguments[2]
        local attribNumber = tonumber(arguments[3])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name), attribName) or lia.util.stringMatches(k, attribName) then
                        character:setAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribSet", target:Name(), L(v.name), math.abs(attribNumber))
                        return
                    end
                end
            end
        end
    end
})

lia.command.add("checkattributes", {
    adminOnly = true,
    syntax = "[string charname]",
    privilege = "Manage Attributes",
    AdminStick = {
        Name = L("checkAttributes"),
        Category = L("characterManagement"),
        SubCategory = L("attributes"),
        Icon = "icon16/zoom.png"
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) then return client:notify(L("targetNotFound")) end
        local attributesData = {}
        for attrKey, attrData in SortedPairsByMemberValue(lia.attribs.list, "name") do
            local currentValue = target:getChar():getAttrib(attrKey, 0) or 0
            local maxValue = hook.Run("GetAttributeMax", target, attrKey) or 100
            local progress = math.Round(currentValue / maxValue * 100, 1)
            table.insert(attributesData, {
                charID = attrData.name,
                name = L(attrData.name),
                current = currentValue,
                max = maxValue,
                progress = progress .. "%"
            })
        end

        lia.util.CreateTableUI(client, L("characterAttributes"), {
            {
                name = L("attributeName"),
                field = "name"
            },
            {
                name = L("currentValue"),
                field = "current"
            },
            {
                name = L("maxValue"),
                field = "max"
            },
            {
                name = L("progress"),
                field = "progress"
            }
        }, attributesData, {
            {
                name = L("changeAttribute"),
                ExtraFields = {
                    ["Amount"] = "text",
                    ["Mode"] = {L("add"), L("set")}
                },
                net = "ChangeAttribute"
            }
        }, client:getChar():getID())
    end,
})

lia.command.add("charaddattrib", {
    superAdminOnly = true,
    AdminStick = {
        Name = L("addAttributes"),
        Category = L("characterManagement"),
        SubCategory = L("attributes"),
        Icon = "icon16/add.png",
        ExtraFields = {
            ["attribute"] = function()
                local attributes = {}
                for _, v in pairs(lia.attribs.list) do
                    table.insert(attributes, L(v.name))
                end
                return attributes, "combo"
            end,
            ["value"] = "text",
        }
    },
    syntax = "[string charname] [string attribname] [number level]",
    privilege = "Manage Attributes",
    onRun = function(client, arguments)
        local attribName = arguments[2]
        local attribNumber = tonumber(arguments[3])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name), attribName) or lia.util.stringMatches(k, attribName) then
                        character:updateAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribUpdate", target:Name(), L(v.name), math.abs(attribNumber))
                        return
                    end
                end
            end
        end
    end
})
