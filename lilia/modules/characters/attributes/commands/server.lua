lia.command.add(
    "charsetattrib",
    {
        superAdminOnly = true,
        syntax = "<string charname> <string attribname> <number level>",
        privilege = "Change Attributes",
        onRun = function(client, arguments)
            local attribName = arguments[2]
            if not attribName then return L("invalidArg", client, 2) end
            local attribNumber = arguments[3]
            attribNumber = tonumber(attribNumber)
            if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local char = target:getChar()
                if char then
                    for k, v in pairs(lia.attribs.list) do
                        if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                            char:setAttrib(k, math.abs(attribNumber))
                            client:notifyLocalized("attribSet", target:Name(), L(v.name, client), math.abs(attribNumber))
                            return
                        end
                    end
                end
            end
        end
    }
)

lia.command.add(
    "charaddattrib",
    {
        superAdminOnly = true,
        syntax = "<string charname> <string attribname> <number level>",
        privilege = "Change Attributes",
        onRun = function(client, arguments)
            local attribName = arguments[2]
            if not attribName then return L("invalidArg", client, 2) end
            local attribNumber = arguments[3]
            attribNumber = tonumber(attribNumber)
            if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
            local target = lia.command.findPlayer(client, arguments[1])
            if IsValid(target) then
                local char = target:getChar()
                if char then
                    for k, v in pairs(lia.attribs.list) do
                        if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                            char:updateAttrib(k, math.abs(attribNumber))
                            client:notifyLocalized("attribUpdate", target:Name(), L(v.name, client), math.abs(attribNumber))
                            return
                        end
                    end
                end
            end
        end
    }
)
