local PLUGIN = PLUGIN
PLUGIN.name = "Doors Saver"
PLUGIN.author = "Leonheart#7476/Taxin2012" -- Ported on Lilia by github.com/John1344
PLUGIN.description = "Saves purchased by players doors."
PLUGIN.DOORS_BUFFER = PLUGIN.DOORS_BUFFER or {}
PLUGIN.DOORS_ACCESS_BUFFER = PLUGIN.DOORS_ACCESS_BUFFER or {}
PLUGIN.DOORS_TITLES_BUFFER = PLUGIN.DOORS_TITLES_BUFFER or {}

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

if SERVER then
    local DOORS_PL = lia.plugin.list.doors

    if not DOORS_PL then
        ErrorNoHalt("Error: No Doors plugin found!\n")

        return
    end

    function PLUGIN:LoadData()
        local data = self:getData() or {}

        if data then
            self.DOORS_BUFFER = data.doors_buff or {}
            self.DOORS_ACCESS_BUFFER = data.doors_acc_buff or {}
            self.DOORS_TITLES_BUFFER = data.titles or {}

            for k, v in next, self.DOORS_BUFFER do
                local door = ents.GetMapCreatedEntity(k)

                if door and door:IsValid() and not door:getNetVar("disabled") then
                    local name = self.DOORS_TITLES_BUFFER[k]

                    if name then
                        door:setNetVar("title", name)
                    end

                    door:setNetVar("noSell", true)

                    DOORS_PL:callOnDoorChildren(door, function(child)
                        child:setNetVar("noSell", true)
                    end)

                    door:Fire("Lock")
                end
            end
        end
    end

    function PLUGIN:SaveDoors()
        local data = {
            doors_buff = self.DOORS_BUFFER,
            doors_acc_buff = self.DOORS_ACCESS_BUFFER,
            titles = self.DOORS_TITLES_BUFFER
        }

        self:setData(data)
    end

    function PLUGIN:SaveData()
        self:SaveDoors()
    end

    function PLUGIN:OnPlayerPurchaseDoor(ply, ent, isBuy)
    end

    --[[local char = ply:getChar()
		if char then
			local door_id = ent:MapCreationID()
			if door_id then
				if isBuy then
					self.DOORS_BUFFER[ door_id ] = char:getID()
				else
					self.DOORS_BUFFER[ door_id ] = nil
					self.DOORS_ACCESS_BUFFER[ door_id ] = nil
				end
			end
		end

		self:SaveDoors()--]]
    function PLUGIN:PlayerLoadedChar(ply, curChar, prevChar)
        if prevChar then
            local prevID = prevChar:getID()

            for k, v in next, self.DOORS_BUFFER do
                if v == prevID then
                    local door = ents.GetMapCreatedEntity(k)

                    if door and door:IsValid() and not door:getNetVar("disabled") then
                        self.DOORS_ACCESS_BUFFER[k] = door.liaAccess
                        self.DOORS_TITLES_BUFFER[k] = door:getNetVar("title", door:getNetVar("name", "Purchased"))
                        door:setNetVar("noSell", true)

                        DOORS_PL:callOnDoorChildren(door, function(child)
                            child:setNetVar("noSell", true)
                        end)
                    end
                end
            end
        end

        local HaveDoor = false
        local curID = curChar:getID()

        for k, v in next, self.DOORS_BUFFER do
            if v == curID then
                local door = ents.GetMapCreatedEntity(k)

                if door and door:IsValid() and not door:getNetVar("disabled") then
                    door:setNetVar("noSell", false)
                    door:SetDTEntity(0, ply)

                    if prevChar then
                        local access = self.DOORS_ACCESS_BUFFER[k]

                        if access then
                            for k, v in next, access do
                                if k and k:IsValid() and k:getChar() then
                                    door.liaAccess = door.liaAccess or {}
                                    door.liaAccess[k] = v
                                end
                            end

                            door.liaAccess = door.liaAccess or {}
                            door.liaAccess[ply] = DOOR_OWNER
                        end
                    else
                        door.liaAccess = {
                            [ply] = DOOR_OWNER
                        }
                    end

                    DOORS_PL:callOnDoorChildren(door, function(child)
                        child:setNetVar("noSell", false)
                        child:SetDTEntity(0, ply)
                    end)

                    local doors = curChar:getVar("doors") or {}
                    doors[#doors + 1] = door
                    curChar:setVar("doors", doors, true)
                    HaveDoor = true
                end
            end
        end

        if HaveDoor then
            self:SaveDoors()
        end
    end

    function PLUGIN:PlayerDisconnected(ply)
        local char = ply:getChar()

        if char then
            local HaveDoor = false
            local charID = char:getID()

            for k, v in next, self.DOORS_BUFFER do
                if v == charID then
                    local door = ents.GetMapCreatedEntity(k)

                    if door and door:IsValid() and not door:getNetVar("disabled") then
                        self.DOORS_ACCESS_BUFFER[k] = door.liaAccess
                        self.DOORS_TITLES_BUFFER[k] = door:getNetVar("title", door:getNetVar("name", "Purchased"))
                        door:setNetVar("noSell", true)

                        DOORS_PL:callOnDoorChildren(door, function(child)
                            child:setNetVar("noSell", true)
                        end)

                        HaveDoor = true
                    end
                end
            end

            if HaveDoor then
                self:SaveDoors()
            end
        end
    end

    function PLUGIN:CharacterDeleted(ply, id)
        local HaveDoor = false

        for k, v in next, self.DOORS_BUFFER do
            if v == id then
                local door = ents.GetMapCreatedEntity(k)

                if door and door:IsValid() and not door:getNetVar("disabled") then
                    self.DOORS_BUFFER[k] = nil
                    self.DOORS_ACCESS_BUFFER[k] = nil
                    self.DOORS_TITLES_BUFFER[k] = nil
                    door:RemoveDoorAccessData()
                    HaveDoor = true
                end
            end
        end

        if HaveDoor then
            self:SaveDoors()
        end
    end
end