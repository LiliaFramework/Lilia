local MODULE = MODULE
local function runCommand(client, args, range)
    local target = lia.util.findPlayer(client, args[1]) or client
    if not IsValid(target) or not target:getChar() then return end
    MODULE:ForceRecognizeRange(target, range)
end

lia.command.add("recogwhisper", {
    privilege = "Manage Recognition",
    adminOnly = true,
    privilege = "Manage Recognition",
    syntax = "[player Name]",
    desc = "recogWhisperDesc",
    AdminStick = {
        Name = "recogWhisperStickName",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments) runCommand(client, arguments, "whisper") end
})

lia.command.add("recognormal", {
    privilege = "Manage Recognition",
    adminOnly = true,
    privilege = "Manage Recognition",
    syntax = "[player Name]",
    desc = "recogNormalDesc",
    AdminStick = {
        Name = "recogNormalStickName",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments) runCommand(client, arguments, "normal") end
})

lia.command.add("recogyell", {
    privilege = "Manage Recognition",
    adminOnly = true,
    privilege = "Manage Recognition",
    syntax = "[player Name]",
    desc = "recogYellDesc",
    AdminStick = {
        Name = "recogYellStickName",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments) runCommand(client, arguments, "yell") end
})

lia.command.add("recogbots", {
    privilege = "Manage Recognition",
    superAdminOnly = true,
    privilege = "Manage Recognition",
    syntax = "[string Range]",
    desc = "recogBotsDesc",
    AdminStick = {
        Name = "recogBotsStickName",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/eye.png"
    },
    onRun = function(_, arguments)
        local range = arguments[1] or "normal"
        for _, ply in player.Iterator() do
            if ply:IsBot() then MODULE:ForceRecognizeRange(ply, range) end
        end
    end
})
