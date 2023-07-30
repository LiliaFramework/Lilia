util.AddNetworkString("classnameviewer")

function MODULE:OpenClassViewer(ply)
    if ply:IsAdmin() then
        net.Start("classnameviewer")
        net.Send(ply)
    end
end