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
net.Receive(
    "moneyprompt",
    function()
        Derma_StringRequest(
            "Give money",
            "How much would you like to give?",
            "0",
            function(text)
                lia.command.send("givemoney", text)
            end,
            function()
                gui.EnableScreenClicker(false)
            end
        )
    end
)
----------------------------------------------------------------------------------------------