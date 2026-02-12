function MODULE:CanPlayerModifyConfig(client)
    return client:hasPrivilege("accessEditConfigurationMenu")
end

properties.Add("TogglePropBlacklist", {
    MenuLabel = L("togglePropBlacklist"),
    Order = 900,
    MenuIcon = "icon16/link.png",
    Filter = function(_, ent, ply) return IsValid(ent) and ent:GetClass() == "prop_physics" and ply:hasPrivilege("managePropBlacklist") end,
    Action = function(self, ent)
        self:MsgStart()
        net.WriteString(ent:GetModel())
        self:MsgEnd()
    end,
    Receive = function(_, _, ply)
        if not ply:hasPrivilege("managePropBlacklist") then return end
        local model = net.ReadString()
        local list = lia.data.get("prop_blacklist", {})
        if table.HasValue(list, model) then
            table.RemoveByValue(list, model)
            lia.data.set("prop_blacklist", list, true, true)
            ply:notifySuccessLocalized("removedFromBlacklist", model)
        else
            table.insert(list, model)
            lia.data.set("prop_blacklist", list, true, true)
            ply:notifySuccessLocalized("addedToBlacklist", model)
        end
    end
})

lia.command.add("sayall", {
    desc = "sendsPhraseToAllChatTypes",
    privilege = "adminChat",
    adminOnly = true,
    arguments = {
        {
            name = "phrase",
            type = "string"
        }
    },
    onRun = function(client, arguments)
        local phrase = table.concat(arguments, " ")
        if not phrase or phrase == "" then
            client:notifyErrorLocalized("invalidPhrase")
            return
        end

        local chatCount = 0
        for chatType, chatData in pairs(lia.chat.classes) do
            if chatData.onCanSay and chatType ~= "adminchat" then
                lia.chat.send(client, chatType, phrase, false)
                chatCount = chatCount + 1
            end
        end

        client:notifySuccessLocalized("sentToAllChats", chatCount, phrase)
    end
})

properties.Add("ToggleCarBlacklist", {
    MenuLabel = L("toggleCarBlacklist"),
    Order = 901,
    MenuIcon = "icon16/link.png",
    Filter = function(_, ent, ply) return IsValid(ent) and (ent:IsVehicle() or ent:isSimfphysCar()) and ply:hasPrivilege("manageVehicleBlacklist") end,
    Action = function(self, ent)
        self:MsgStart()
        net.WriteString(ent:GetModel())
        self:MsgEnd()
    end,
    Receive = function(_, _, ply)
        if not ply:hasPrivilege("manageVehicleBlacklist") then return end
        local model = net.ReadString()
        local list = lia.data.get("carBlacklist", {})
        if table.HasValue(list, model) then
            table.RemoveByValue(list, model)
            lia.data.set("carBlacklist", list, true, true)
            ply:notifySuccessLocalized("removedFromBlacklist", model)
        else
            table.insert(list, model)
            lia.data.set("carBlacklist", list, true, true)
            ply:notifySuccessLocalized("addedToBlacklist", model)
        end
    end
})

properties.Add("copytoclipboard", {
    MenuLabel = L("copyModelClipboard"),
    Order = 999,
    MenuIcon = "icon16/cup.png",
    Filter = function(_, ent)
        if ent == nil then return false end
        if not IsValid(ent) then return false end
        return true
    end,
    Action = function(self, ent)
        self:MsgStart()
        local s = ent:GetModel()
        SetClipboardText(s)
        self:MsgEnd()
    end,
})

lia.util.setPositionCallback("Faction Spawn Adder", {
    onRun = function(pos, client, typeId)
        if SERVER then
            local factionID = net.ReadString()
            if not factionID or factionID == "" then return end
            local factionInfo = lia.faction.teams[factionID] or lia.util.findFaction(client, factionID)
            if not factionInfo then return end
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                spawns[factionInfo.uniqueID] = spawns[factionInfo.uniqueID] or {}
                table.insert(spawns[factionInfo.uniqueID], {
                    pos = pos,
                    ang = angle_zero,
                    map = lia.data.getEquivalencyMap(game.GetMap())
                })

                lia.module.get("spawns"):StoreSpawns(spawns):next(function()
                    lia.log.add(client, "spawnAdd", factionInfo.name)
                    client:notifySuccessLocalized("spawnAdded", L(factionInfo.name))
                end)
            end)
        else
            local names, idByDisplay = {}, {}
            for k, v in pairs(lia.faction.teams or {}) do
                local display = L(v.name) or v.name or k
                names[#names + 1] = display
                idByDisplay[display] = k
            end

            if #names == 0 then
                client:notifyErrorLocalized("invalidFaction")
                return
            end

            lia.derma.requestDropdown("Faction Spawn Adder", names, function(selection)
                if not selection or selection == false then return end
                local factionID = idByDisplay[selection]
                if not factionID then return end
                net.Start("liaSetFeaturePosition")
                net.WriteString("faction_spawn_adder")
                net.WriteVector(pos)
                net.WriteString(factionID)
                net.SendToServer()
            end)
        end
    end,
    onSelect = function(client, callback)
        if SERVER then
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                local list = {}
                local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
                for factionID, factionSpawns in pairs(spawns or {}) do
                    local factionInfo = lia.faction.get(factionID)
                    local label = factionInfo and (factionInfo.name and L(factionInfo.name) or factionID) or factionID
                    for i = 1, #(factionSpawns or {}) do
                        local data = factionSpawns[i]
                        local pos = data.pos or data.position
                        if isvector(pos) then
                            local map = data.map and (isstring(data.map) and data.map:lower() or tostring(data.map):lower()) or nil
                            if not map or map == curMap then
                                list[#list + 1] = {
                                    pos = pos,
                                    label = label
                                }
                            end
                        end
                    end
                end

                callback(list, #list)
            end)
        else
            net.Start("liaFeaturePositionsRequest")
            net.WriteString("faction_spawn_adder")
            net.SendToServer()
        end
    end,
    color = Color(100, 200, 100),
    serverOnly = true
})

lia.util.setPositionCallback("Class Spawn Adder", {
    onRun = function(pos, client, typeId)
        if SERVER then
            local classID = net.ReadString()
            if not classID or classID == "" then return end
            local classIDNum = tonumber(classID) or lia.class.retrieveClass(classID)
            local classData = lia.class.get(classIDNum)
            if not classData then return end
            local stored = lia.data.get("spawns", {})
            local data = istable(stored) and stored or {}
            data.classes = data.classes or {}
            data.classes[classIDNum] = data.classes[classIDNum] or {}
            table.insert(data.classes[classIDNum], {
                pos = pos,
                ang = angle_zero,
                map = lia.data.getEquivalencyMap(game.GetMap())
            })

            lia.data.set("spawns", data)
            lia.log.add(client, "classSpawnAdd", classData.name)
            client:notifySuccessLocalized("spawnAdded", L(classData.name))
        else
            local names, idByDisplay = {}, {}
            for k, v in pairs(lia.class.list or {}) do
                if isnumber(k) and istable(v) and v.name then
                    local display = L(v.name) or v.name or tostring(k)
                    names[#names + 1] = display
                    idByDisplay[display] = tostring(k)
                end
            end

            if #names == 0 then
                client:notifyErrorLocalized("invalidClass")
                return
            end

            lia.derma.requestDropdown("Class Spawn Adder", names, function(selection)
                if not selection or selection == false then return end
                local classID = idByDisplay[selection]
                if not classID then return end
                net.Start("liaSetFeaturePosition")
                net.WriteString("class_spawn_adder")
                net.WriteVector(pos)
                net.WriteString(classID)
                net.SendToServer()
            end)
        end
    end,
    onSelect = function(client, callback)
        if SERVER then
            local stored = lia.data.get("spawns", {})
            local data = istable(stored) and stored or {}
            local classes = data.classes or {}
            local list = {}
            local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
            for classID, classSpawns in pairs(classes) do
                local classData = lia.class.get(tonumber(classID))
                local label = classData and (classData.name and L(classData.name) or tostring(classID)) or tostring(classID)
                for i = 1, #(classSpawns or {}) do
                    local spawnData = classSpawns[i]
                    local pos = spawnData.pos or spawnData.position
                    if isvector(pos) then
                        local map = spawnData.map and (isstring(spawnData.map) and spawnData.map:lower() or tostring(spawnData.map):lower()) or nil
                        if not map or map == curMap then
                            list[#list + 1] = {
                                pos = pos,
                                label = label
                            }
                        end
                    end
                end
            end

            callback(list, #list)
        else
            net.Start("liaFeaturePositionsRequest")
            net.WriteString("class_spawn_adder")
            net.SendToServer()
        end
    end,
    color = Color(200, 150, 100),
    serverOnly = true
})

lia.util.setPositionCallback("Sit Room", {
    onRun = function(pos, client, typeId)
        if SERVER then
            local name = net.ReadString()
            if not name or name == "" then return end
            local rooms = lia.data.get("sitrooms", {})
            rooms[name] = pos
            lia.data.set("sitrooms", rooms)
            client:notifySuccessLocalized("sitroomSet")
            lia.log.add(client, "sitRoomSet", L("sitroomSetDetail", name, tostring(pos)), L("logSetSitroom"))
        elseif CLIENT then
            client:requestString(L("enterNamePrompt"), L("enterSitroomPrompt") .. ":", function(name)
                if name == false then return end
                if not name or name == "" then
                    client:notifyErrorLocalized("invalidName")
                    return
                end

                net.Start("liaSetFeaturePosition")
                net.WriteString("sit_room")
                net.WriteVector(pos)
                net.WriteString(name)
                net.SendToServer()
            end)
        end
    end,
    onSelect = function(client, callback)
        if SERVER then
            local rooms = lia.data.get("sitrooms", {})
            local list = {}
            for name, pos in pairs(rooms) do
                if isvector(pos) then
                    list[#list + 1] = {
                        pos = pos,
                        label = name
                    }
                end
            end

            callback(list, #list)
        elseif CLIENT then
            net.Start("liaFeaturePositionsRequest")
            net.WriteString("sit_room")
            net.SendToServer()
        end
    end,
    color = Color(123, 104, 238),
    serverOnly = true
})
