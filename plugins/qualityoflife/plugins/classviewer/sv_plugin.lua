util.AddNetworkString("classnameviewer")

function PLUGIN:OpenClassViewer(ply)
    if ply:IsAdmin() then
        net.Start("classnameviewer")
        net.Send(ply)
    end
end