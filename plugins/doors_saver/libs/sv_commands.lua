lia.command.add("doorsetperm", {
    adminOnly = true,
    syntax = "<bool perm>",
    onRun = function(client, arguments)
        -- Get the door the player is looking at.
        local entity = client:GetEyeTrace().Entity

        -- Validate it is a door.
        if IsValid(entity) and entity:isDoor() then
            local perm = util.tobool(arguments[1] or true)
            local owner = entity:GetDTEntity(0)

            if perm and not owner then
                owner:notify("ERROR: Nobody owns this door")

                return
            end

            local char = owner:getChar()

            if perm and not char then
                owner:notify("ERROR: Nobody owns this door")

                return
            end

            local door_id = entity:MapCreationID()

            if door_id then
                if perm then
                    PLUGIN.DOORS_BUFFER[door_id] = char:getID()
                else
                    PLUGIN.DOORS_BUFFER[door_id] = nil
                    PLUGIN.DOORS_ACCESS_BUFFER[door_id] = nil
                    PLUGIN.DOORS_TITLES_BUFFER[door_id] = nil
                end
            end

            PLUGIN:SaveDoors()
            -- Tell the player they have made the door (un)disabled.
            client:notify("Success")
        else
            -- Tell the player the door isn't valid.
            client:notifyLocalized("dNotValid")
        end
    end
})