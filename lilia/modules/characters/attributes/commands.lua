lia.command.add("charsetattrib", {
    superAdminOnly = true,
    syntax = "[string charname] [string attribname] [number level]",
    privilege = "Manage Attributes",
    AdminStick = {
        Name = "Set Attributes",
        Category = "Character Management",
        SubCategory = "Attributes",
        ExtraFields = {
            ["attribute"] = function()
                local attributes = {}
                for k, v in pairs(lia.attribs.list) do
                    table.insert(attributes, v.name)
                end
                return attributes, "combo"
            end,
            ["value"] = "text",
        }
    },
    onRun = function(client, arguments)
        local attribName = arguments[2]
        if not attribName then return L("invalidArg", 2) end
        local attribNumber = tonumber(arguments[3])
        if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", 3) end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                        character:setAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribSet", target:Name(), L(v.name, client), math.abs(attribNumber))
                        return
                    end
                end
            end
        end
    end
})

lia.command.add("charaddattrib", {
    superAdminOnly = true,
    AdminStick = {
        Name = "Add Attributes",
        Category = "Character Management",
        SubCategory = "Attributes",
        ExtraFields = {
            ["attribute"] = function()
                local attributes = {}
                for k, v in pairs(lia.attribs.list) do
                    table.insert(attributes, k)
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
        if not attribName then return L("invalidArg", 2) end
        local attribNumber = tonumber(arguments[3])
        if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", 3) end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local character = target:getChar()
            if character then
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                        character:updateAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribUpdate", target:Name(), L(v.name, client), math.abs(attribNumber))
                        return
                    end
                end
            end
        end
    end
})