local MODULE = MODULE
local function runCommand(client, args, range)
    local target = lia.util.findPlayer(client, args[1]) or client
    if not IsValid(target) or not target:getChar() then return end
    MODULE:ForceRecognizeRange(target, range)
end

lia.command.add("recogwhisper", {
    privilege = "Manage Recognition",
    adminOnly = true,
    syntax = "[player Name]",
    desc = L("recogWhisperDesc"),
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
    syntax = "[player Name]",
    desc = L("recogNormalDesc"),
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
    syntax = "[player Name]",
    desc = L("recogYellDesc"),
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
    syntax = "[string Range optional] [string Name optional]",
    desc = L("recogBotsDesc"),
    AdminStick = {
        Name = "recogBotsStickName",
        Category = "moderationTools",
        SubCategory = "misc",
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
