local PLUGIN = PLUGIN


function PLUGIN:ScoreboardHide()
    if IsValid(lia.gui.score) then
        lia.gui.score:SetVisible(false)
        CloseDermaMenus()
    end

    gui.EnableScreenClicker(false)

    return true
end

function PLUGIN:ScoreboardShow()
    if IsValid(lia.gui.score) then
        lia.gui.score:SetVisible(true)
    else
        vgui.Create("liaScoreboard")
    end

    gui.EnableScreenClicker(true)

    return true
end

function PLUGIN:OnReloaded()
    -- Reload the scoreboard.
    if IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end
end

function PLUGIN:ShowPlayerOptions(client, options)
    if UserGroups.StaffRanks[LocalPlayer():GetUserGroup()] then
        options["Player Profile"] = {
            "icon16/user.png", function()
                if IsValid(client) then
                    client:ShowProfile()
                end
            end
        }

        options["Player Steam ID"] = {
            "icon16/user.png", function()
                if IsValid(client) then
                    SetClipboardText(client:SteamID())
                end
            end
        }

        options["Move To Player"] = {
            "icon16/wand.png", function()
                LocalPlayer():ConCommand("say !goto " .. client:SteamID())
            end
        }

        options["Bring Player"] = {
            "icon16/arrow_down.png", function()
                if IsValid(client) then
                    LocalPlayer():ConCommand("say !bring " .. client:SteamID())
                end
            end
        }

        options["Return Player"] = {
            "icon16/arrow_down.png", function()
                if IsValid(client) then
                    LocalPlayer():ConCommand("say !return " .. client:SteamID())
                end
            end
        }
    end
end