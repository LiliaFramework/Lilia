if SERVER then
    local MODULE = MODULE

    local rangeMap = {
        whisper = "w",
        normal = "ic",
        talk = "ic",
        yell = "y"
    }

    function MODULE:ForceRecognizeRange(ply, range)
        local char = ply:getChar()
        if not (char and ply:Alive()) then return end
        local key = rangeMap[range] or "ic"
        local cls = lia.chat.classes[key]
        if not cls then return end

        for _, v in player.Iterator() do
            if v ~= ply and v:getChar() and cls.onCanHear(ply, v) then
                if v:getChar():recognize(char) then
                    lia.log.add(ply, "charRecognize", v:getChar():getID(), "FORCED")
                end
            end
        end

        net.Start("rgnDone")
        net.Send(ply)
        hook.Run("OnCharRecognized", ply)
    end

    local function runCommand(client, args, range)
        local target = lia.util.findPlayer(client, args[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        MODULE:ForceRecognizeRange(target, range)
    end

    lia.command.add("recogwhisper", {
        adminOnly = true,
        syntax = "[player Name]",
        desc = "recogWhisperDesc",
        onRun = function(client, arguments) runCommand(client, arguments, "whisper") end
    })

    lia.command.add("recognormal", {
        adminOnly = true,
        syntax = "[player Name]",
        desc = "recogNormalDesc",
        onRun = function(client, arguments) runCommand(client, arguments, "normal") end
    })

    lia.command.add("recogyell", {
        adminOnly = true,
        syntax = "[player Name]",
        desc = "recogYellDesc",
        onRun = function(client, arguments) runCommand(client, arguments, "yell") end
    })

    lia.command.add("recogbots", {
        superAdminOnly = true,
        syntax = "[string Range]",
        desc = "recogBotsDesc",
        onRun = function(_, arguments)
            local range = arguments[1] or "normal"
            for _, ply in player.Iterator() do
                if ply:IsBot() then MODULE:ForceRecognizeRange(ply, range) end
            end
        end
    })
end
