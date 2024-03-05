function MODULE:LoadData()
    local screen = ents.Create("gmod_playx")
    screen:SetModel("models/dav0r/camera.mdl")
    screen:SetPos(self.screenPos)
    screen:SetAngles(self.screenAng)
    screen:SetRenderMode(RENDERMODE_TRANSALPHA)
    screen:SetColor(Color(255, 255, 255, 1))
    screen:Spawn()
    screen:Activate()
    local phys = screen:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
    end
end

function MODULE:KeyPress(client, key)
    if key == IN_USE then
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 84
        data.filter = client
        local entity = util.TraceLine(data).Entity
        local isController = false
        if IsValid(entity) then
            for _, v in pairs(self.controllers) do
                if entity:MapCreationID() == v then isController = true end
            end
        end

        if isController then
            if not client:HasFlag("m") then
                PlayX.SendError(client, "You do not have permission to use the player")
                return
            end

            client.nextMusicUse = client.nextMusicUse or 0
            if CurTime() > client.nextMusicUse then
                netstream.Start(client, "RequestPlayxURL")
                client.nextMusicUse = CurTime() + 1.5
            end
        end
    end
end
