local sitroom = MODULE

local function canUseSitroomCommand(client, command)
    return sitroom:CanUseCommand(client, command), "Manage Administration Rooms"
end

lia.command.add("managesitrooms", {
    superAdminOnly = true,
    desc = "Manage administration rooms on the current map: view existing administration rooms, teleport to them, rename them, or reposition them.",
    onCheckAccess = canUseSitroomCommand,
    onRun = function(client)
        net.Start("liaManagesitrooms")
        net.WriteTable(sitroom:GetRooms())
        net.Send(client)
    end
})

lia.command.add("addsitroom", {
    superAdminOnly = true,
    desc = "Set Administration Room",
    onCheckAccess = canUseSitroomCommand,
    onRun = function(client)
        client:requestString("Enter Name", "Enter the name of the Administration Room(" .. "):", function(name)
            if not sitroom:CanUseCommand(client, "addsitroom") then return end
            name = sitroom:NormalizeName(name)
            if name == "" then
                client:notifyError("Invalid name!")
                return
            end

            if sitroom:SetRoom(name, client:GetPos()) then client:notifySuccess("Administration Room has been set!") end
        end)
    end
})

lia.command.add("sendtositroom", {
    adminOnly = true,
    desc = "Send a player to an Administration Room",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Send To Administration Room",
        ButtonText = "Send To Sit Room",
        Category = "Teleportation",
    },
    onCheckAccess = canUseSitroomCommand,
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not IsValid(target) then
            client:notifyError("Target not found")
            return
        end

        local rooms = sitroom:GetRooms()
        local names = {}
        for name in pairs(rooms) do
            names[#names + 1] = name
        end

        if #names == 0 then
            client:notifyError("No Administration Room has been set!")
            return
        end

        client:requestDropdown("Choose an Administration Room", "Select an Administration Room to send the player to(" .. "):", names, function(selection)
            if not sitroom:CanUseCommand(client, "sendtositroom") then return end
            local pos = sitroom:GetRooms()[selection]
            if not isvector(pos) then
                client:notifyError("No Administration Room has been set!")
                return
            end

            if not sitroom:Teleport(target, pos, true) then
                client:notifyError("Unable to teleport target")
                return
            end

            client:notifySuccess(string.format("You have been teleported to Administration Room: %s.", target:Nick()))
            target:notifyInfo("You have arrived at an Administration Room.")
        end)
    end
})

lia.command.add("returnsitroom", {
    adminOnly = true,
    desc = "Returns you or the specified player to their previous position before teleporting to an administration room.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Return From Administration Room",
        ButtonText = "Return From Sit Room",
        Category = "Teleportation",
    },
    onCheckAccess = canUseSitroomCommand,
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) then
            client:notifyError("Target not found")
            return
        end

        if not sitroom:Return(target) then
            client:notifyError("No previous sitroom position")
            return
        end

        client:notifySuccess("Successfully returned to sitroom")
        if target ~= client then target:notifyInfo("Returned to your previous position.") end
    end
})
