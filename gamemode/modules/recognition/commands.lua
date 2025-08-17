local MODULE = MODULE
local function runCommand(client, args, range)
    local target = lia.util.findPlayer(client, args[1]) or client
    if not IsValid(target) or not target:getChar() then return end
    MODULE:ForceRecognizeRange(target, range)
end

lia.command.add("recogwhisper", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    desc = "recogWhisperDesc",
    AdminStick = {
        Name = "recogWhisperStickName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments) runCommand(client, arguments, "whisper") end
})

lia.command.add("recognormal", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    desc = "recogNormalDesc",
    AdminStick = {
        Name = "recogNormalStickName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments) runCommand(client, arguments, "normal") end
})

lia.command.add("recogyell", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    desc = "recogYellDesc",
    AdminStick = {
        Name = "recogYellStickName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments) runCommand(client, arguments, "yell") end
})

lia.command.add("recogbots", {
    superAdminOnly = true,
    arguments = {
        {
            name = "range",
            type = "string",
            optional = true
        },
        {
            name = "name",
            type = "string",
            optional = true
        },
    },
    desc = "recogBotsDesc",
    AdminStick = {
        Name = "recogBotsStickName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/eye.png"
    },
    onRun = function(_, arguments)
        local range = arguments[1] or "normal"
        local fakeName = arguments[2]
        for _, ply in player.Iterator() do
            if ply:IsBot() then MODULE:ForceRecognizeRange(ply, range, fakeName) end
        end
    end
})