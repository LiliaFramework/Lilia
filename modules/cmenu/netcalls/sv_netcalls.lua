----------------------------------------------------------------------------------------------
net.Receive(
    "liaApproveID",
    function(len, ply)
        local requester = ply.IDRequested
        if not requester then return end
        if not requester.IDRequested then return end
        local approveIDView = net.ReadBool()
        if not approveIDView then
            requester:notify("Player denied your request to view their inventory.")
            requester.IDRequested = nil
            ply.IDRequested = nil

            return
        end

        if requester:GetPos():DistToSqr(ply:GetPos()) > 250 * 250 then return end
        netstream.Start(requester, "openUpID", ply)
        requester.IDRequested = nil
        ply.IDRequested = nil
    end
)
----------------------------------------------------------------------------------------------