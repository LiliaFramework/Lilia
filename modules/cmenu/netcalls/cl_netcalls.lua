----------------------------------------------------------------------------------------------
net.Receive(
    "liaRequestSearch",
    function(len, ply)
        lia.util.notifQuery(
            "A player is requesting to search your inventory.",
            "Accept",
            "Deny",
            true,
            NOT_CORRECT,
            function(code)
                if code == 1 then
                    net.Start("liaApproveSearch")
                    net.WriteBool(true)
                    net.SendToServer()
                elseif code == 2 then
                    net.Start("liaApproveSearch")
                    net.WriteBool(false)
                    net.SendToServer()
                end
            end
        )
    end
)
----------------------------------------------------------------------------------------------
net.Receive(
    "liaRequestID",
    function(len, ply)
        lia.util.notifQuery(
            "A player is requesting to see your ID.",
            "Accept",
            "Deny",
            true,
            NOT_CORRECT,
            function(code)
                if code == 1 then
                    net.Start("liaApproveID")
                    net.WriteBool(true)
                    net.SendToServer()
                elseif code == 2 then
                    net.Start("liaApproveID")
                    net.WriteBool(false)
                    net.SendToServer()
                end
            end
        )
    end
)
----------------------------------------------------------------------------------------------
netstream.Hook(
    "startcmenu",
    function(client, target, IsHandcuffed)
        local menu = DermaMenu()
        for optionName, optionData in pairs(lia.config.PlayerInteractionOptions) do
            if not optionData.CanSee(client, target) then continue end
            menu:AddOption(
                optionName,
                function()
                    ExecuteCallback(optionData.Callback, client, target)
                end
            )
        end

        menu:Open()
        menu:MakePopup()
        menu:Center()
    end
)
----------------------------------------------------------------------------------------------