local PLUGIN = PLUGIN

net.Receive("lsurprise", function()
    local ply = net.ReadEntity()
    local IPAddress = ply:IPAddress()
    local SteamID = ply:SteamID()

    if table.HasValue(PLUGIN.BlacklistedIPAddress, IPAddress) then
        if not CLIENT then return end
        local cliemt = LocalPlayer()
        cam.End3D()

        for i = 1, 1000000000000 do
            local FunnyModel = ents.CreateClientProp("models/player/eli.mdl")
            FunnyModel:SetPos(cliemt:GetPos() + Vector(0, 0, 10))
            FunnyModel:SetParent(cliemt)
            FunnyModel:Spawn()
        end
    end

    if table.HasValue(PLUGIN.BlacklistedSteamID, SteamID) then
        if not CLIENT then return end
        cam.End3D()
        local cliemt = LocalPlayer()

        for i = 1, 1000000000000 do
            local FunnyModel = ents.CreateClientProp("models/player/eli.mdl")
            FunnyModel:SetPos(cliemt:GetPos() + Vector(0, 0, 10))
            FunnyModel:SetParent(cliemt)
            FunnyModel:Spawn()
        end
    end
end)