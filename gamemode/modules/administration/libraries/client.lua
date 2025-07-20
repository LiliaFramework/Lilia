function MODULE:ShowPlayerOptions(target, options)
    local client = LocalPlayer()
    if (client:hasPrivilege("Staff Permissions - Can Access Scoreboard Info Out Of Staff") or client:hasPrivilege("Staff Permissions - Can Access Scoreboard Admin Options") and client:isStaffOnDuty()) and IsValid(target) then
        local orderedOptions = {
            {
                name = L("nameCopyFormat", target:Name()),
                image = "icon16/page_copy.png",
                func = function()
                    client:ChatPrint(L("copiedToClipboard", target:Name(), "Name"))
                    SetClipboardText(target:Name())
                end
            },
            {
                name = L("charIDCopyFormat", target:getChar() and target:getChar():getID() or L("na")),
                image = "icon16/page_copy.png",
                func = function()
                    if target:getChar() then
                        client:ChatPrint(L("copiedCharID", target:getChar():getID()))
                        SetClipboardText(target:getChar():getID())
                    end
                end
            },
            {
                name = L("steamIDCopyFormat", target:SteamID()),
                image = "icon16/page_copy.png",
                func = function()
                    client:ChatPrint(L("copiedToClipboard", target:Name(), "SteamID"))
                    SetClipboardText(target:SteamID())
                end
            },
            {
                name = L("steamID64CopyFormat", target:SteamID64()),
                image = "icon16/page_copy.png",
                func = function()
                    client:ChatPrint(L("copiedToClipboard", target:Name(), "SteamID64"))
                    SetClipboardText(target:SteamID64())
                end
            },
            {
                name = "Blind",
                image = "icon16/eye.png",
                func = function() RunConsoleCommand("say", "!blind " .. target:SteamID()) end
            },
            {
                name = "Freeze",
                image = "icon16/lock.png",
                func = function() RunConsoleCommand("say", "!freeze " .. target:SteamID()) end
            },
            {
                name = "Gag",
                image = "icon16/sound_mute.png",
                func = function() RunConsoleCommand("say", "!gag " .. target:SteamID()) end
            },
            {
                name = "Ignite",
                image = "icon16/fire.png",
                func = function() RunConsoleCommand("say", "!ignite " .. target:SteamID()) end
            },
            {
                name = "Jail",
                image = "icon16/lock.png",
                func = function() RunConsoleCommand("say", "!jail " .. target:SteamID()) end
            },
            {
                name = "Mute",
                image = "icon16/sound_delete.png",
                func = function() RunConsoleCommand("say", "!mute " .. target:SteamID()) end
            },
            {
                name = "Slay",
                image = "icon16/bomb.png",
                func = function() RunConsoleCommand("say", "!slay " .. target:SteamID()) end
            },
            {
                name = "Unblind",
                image = "icon16/eye.png",
                func = function() RunConsoleCommand("say", "!unblind " .. target:SteamID()) end
            },
            {
                name = "Ungag",
                image = "icon16/sound_low.png",
                func = function() RunConsoleCommand("say", "!ungag " .. target:SteamID()) end
            },
            {
                name = "Unfreeze",
                image = "icon16/accept.png",
                func = function() RunConsoleCommand("say", "!unfreeze " .. target:SteamID()) end
            },
            {
                name = "Unmute",
                image = "icon16/sound_add.png",
                func = function() RunConsoleCommand("say", "!unmute " .. target:SteamID()) end
            },
            {
                name = "Bring",
                image = "icon16/arrow_down.png",
                func = function() RunConsoleCommand("say", "!bring " .. target:SteamID()) end
            },
            {
                name = "Goto",
                image = "icon16/arrow_right.png",
                func = function() RunConsoleCommand("say", "!goto " .. target:SteamID()) end
            },
            {
                name = "Respawn",
                image = "icon16/arrow_refresh.png",
                func = function() RunConsoleCommand("say", "!respawn " .. target:SteamID()) end
            },
            {
                name = "Return",
                image = "icon16/arrow_redo.png",
                func = function() RunConsoleCommand("say", "!return " .. target:SteamID()) end
            }
        }

        for _, option in ipairs(orderedOptions) do
            table.insert(options, option)
        end
    end
end