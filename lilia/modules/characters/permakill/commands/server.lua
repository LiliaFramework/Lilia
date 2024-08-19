lia.command.add("pktoggle", {
    adminOnly = true,
    privilege = "Toogle Permakill",
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local tcharacter = target:getChar()
        if tcharacter:getData("PermaKillFlagged", false) then
            tcharacter:setData("PermaKillFlagged", false)
            client:notify("You have toggled this character's PK State to False.")
        else
            tcharacter:setData("PermaKillFlagged", true)
            client:notify("You have toggled this character's PK State to True. He will be PK'ed the next time he dies!")
        end
    end
})

lia.command.add("charPK", {
    superAdminOnly = true,
    privilege = "Force Permakill",
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target and target:getChar() then
            local tcharacter = target:getChar()
            tcharacter:ban()
            client:notify("You have permanently killed " .. target:Name() .. "'s character.")
            target:notify("Your character has been permanently killed by " .. client:Name() .. ".")
        else
            client:notify("Target player not found or they do not have an active character.")
        end
    end
})