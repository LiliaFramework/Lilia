local MODULE = MODULE

-- Strength Command
lia.command.add("rollstrength", {
    syntax = "[number maximum]",
    onRun = function(client, arguments)
        local character = client:getChar()
        local maximum = math.Clamp(arguments[1] or 100, 0, 100)
        local value = math.random(0, maximum) + (character:getAttrib("strength", 0) * MODULE.RollMultiplier)
        lia.chat.send(client, "roll", tostring(value))
        lia.chat.send(client, "me", "has rolled a Strength skill roll")
    end
})

-- Endurance Command
lia.command.add("rollendurance", {
    syntax = "[number maximum]",
    onRun = function(client, arguments)
        local character = client:getChar()
        local maximum = math.Clamp(arguments[1] or 100, 0, 100)
        local value = math.random(0, maximum) + (character:getAttrib("endurance", 0) * MODULE.RollMultiplier)
        lia.chat.send(client, "roll", tostring(value))
        lia.chat.send(client, "me", "has rolled an Endurance skill roll")
    end
})