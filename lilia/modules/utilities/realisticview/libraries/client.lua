local RealisticViewEnabled = CreateClientConVar("rview_enabled", 0, true)
local RealisticViewUseFullBody = CreateClientConVar("rview_fullbody", 0, true)
function Realistic1stPersonView:CalcView(client, origin, angles)
    if self.FirstPersonViewEnabled then
        local view = {
            origin = origin,
            angles = angles,
            fov = 90,
            drawviewer = true
        }

        local head = client:LookupAttachment("eyes")
        head = client:GetAttachment(head)
        if (not head or not head.Pos) or IsValid(lia.gui.menu) or client:GetMoveType() == MOVETYPE_NOCLIP or not RealisticViewEnabled:GetBool() then return end
        if not client.BonesRattled then
            client.BonesRattled = true
            client:InvalidateBoneCache()
            client:SetupBones()
            local matrix
            for bone = 0, client:GetBoneCount() or 1 do
                if client:GetBoneName(bone):lower():find("head") then
                    matrix = client:GetBoneMatrix(bone)
                    break
                end
            end

            if IsValid(matrix) then
                matrix:SetScale(Vector(0, 0, 0))
            end
        end

        view.origin = head.Pos + head.Ang:Up()
        if RealisticViewUseFullBody:GetBool() then
            view.angles = head.Ang
        else
            view.angles = Angle(head.Ang.p, head.Ang.y, angles.r)
        end

        return view
    end
end

function Realistic1stPersonView:SetupQuickMenu(menu)
    if self.FirstPersonViewEnabled then
        menu:addCheck(
            "Realistic View Enabled",
            function(_, state)
                if state then
                    RunConsoleCommand("rview_enabled", "1")
                else
                    RunConsoleCommand("rview_enabled", "0")
                end
            end, RealisticViewEnabled:GetBool()
        )

        menu:addCheck(
            "Realistic View Uses Full Body",
            function(_, state)
                if state then
                    RunConsoleCommand("rview_fullbody", "1")
                else
                    RunConsoleCommand("rview_fullbody", "0")
                end
            end, RealisticViewUseFullBody:GetBool()
        )

        menu:addSpacer()
    end
end