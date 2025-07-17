local function quote(str)
    return string.format("'%s'", tostring(str))
end

function MODULE:RunAdminSystemCommand(cmd, _, victim, dur, reason)
    local id = IsValid(victim) and victim:SteamID() or tostring(victim)
    if cmd == "kick" then
        RunConsoleCommand("say", "/plykick " .. quote(id) .. (reason and " " .. quote(reason) or ""))
        return true
    elseif cmd == "ban" then
        RunConsoleCommand("say", "/plyban " .. quote(id) .. " " .. tostring(dur or 0) .. (reason and " " .. quote(reason) or ""))
        return true
    elseif cmd == "unban" then
        RunConsoleCommand("say", "/plyunban " .. quote(id))
        return true
    elseif cmd == "mute" then
        RunConsoleCommand("say", "/plymute " .. quote(id) .. " " .. tostring(dur or 0) .. (reason and " " .. quote(reason) or ""))
        return true
    elseif cmd == "unmute" then
        RunConsoleCommand("say", "/plyunmute " .. quote(id))
        return true
    elseif cmd == "gag" then
        RunConsoleCommand("say", "/plygag " .. quote(id) .. " " .. tostring(dur or 0) .. (reason and " " .. quote(reason) or ""))
        return true
    elseif cmd == "ungag" then
        RunConsoleCommand("say", "/plyungag " .. quote(id))
        return true
    elseif cmd == "freeze" then
        RunConsoleCommand("say", "/plyfreeze " .. quote(id) .. " " .. tostring(dur or 0))
        return true
    elseif cmd == "unfreeze" then
        RunConsoleCommand("say", "/plyunfreeze " .. quote(id))
        return true
    elseif cmd == "slay" then
        RunConsoleCommand("say", "/plyslay " .. quote(id))
        return true
    elseif cmd == "bring" then
        RunConsoleCommand("say", "/plybring " .. quote(id))
        return true
    elseif cmd == "goto" then
        RunConsoleCommand("say", "/plygoto " .. quote(id))
        return true
    elseif cmd == "return" then
        RunConsoleCommand("say", "/plyreturn " .. quote(id))
        return true
    elseif cmd == "jail" then
        RunConsoleCommand("say", "/plyjail " .. quote(id) .. " " .. tostring(dur or 0))
        return true
    elseif cmd == "unjail" then
        RunConsoleCommand("say", "/plyunjail " .. quote(id))
        return true
    elseif cmd == "cloak" then
        RunConsoleCommand("say", "/plycloak " .. quote(id))
        return true
    elseif cmd == "uncloak" then
        RunConsoleCommand("say", "/plyuncloak " .. quote(id))
        return true
    elseif cmd == "god" then
        RunConsoleCommand("say", "/plygod " .. quote(id))
        return true
    elseif cmd == "ungod" then
        RunConsoleCommand("say", "/plyungod " .. quote(id))
        return true
    elseif cmd == "ignite" then
        RunConsoleCommand("say", "/plyignite " .. quote(id) .. " " .. tostring(dur or 0))
        return true
    elseif cmd == "extinguish" or cmd == "unignite" then
        RunConsoleCommand("say", "/plyextinguish " .. quote(id))
        return true
    elseif cmd == "strip" then
        RunConsoleCommand("say", "/plystrip " .. quote(id))
        return true
    elseif cmd == "respawn" then
        RunConsoleCommand("say", "/plyrespawn " .. quote(id))
        return true
    elseif cmd == "blind" then
        RunConsoleCommand("say", "/plyblind " .. quote(id))
        return true
    elseif cmd == "unblind" then
        RunConsoleCommand("say", "/plyunblind " .. quote(id))
        return true
    end
end

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
