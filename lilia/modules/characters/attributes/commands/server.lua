lia.command.add("charsetattrib", {
    superAdminOnly = true,
    syntax = "<string charname> <string attribname> <number level>",
    privilege = "Manage Attributes",
    onRun = function(client, arguments)
        local attribName = arguments[2]
        if not attribName then return L("invalidArg", 2) end
        local attribNumber = arguments[3]
        attribNumber = tonumber(attribNumber)
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
    syntax = "<string charname> <string attribname> <number level>",
    privilege = "Manage Attributes",
    onRun = function(client, arguments)
        local attribName = arguments[2]
        if not attribName then return L("invalidArg", 2) end
        local attribNumber = arguments[3]
        attribNumber = tonumber(attribNumber)
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