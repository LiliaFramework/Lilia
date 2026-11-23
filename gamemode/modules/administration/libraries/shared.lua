function MODULE:CanPlayerModifyConfig(client)
    local hasPrivilege = client:hasPrivilege("accessEditConfigurationMenu")
    lia.debug("[Permissions]", "Permission Check for function MODULE:CanPlayerModifyConfig", "hasPrivilege(accessEditConfigurationMenu)=", tostring(hasPrivilege), "finalResult=", tostring(hasPrivilege))
    return hasPrivilege
end

function lia.admin.canUseDebugProperties(client)
    if not CLIENT then return false end
    client = client or LocalPlayer()
    if not IsValid(client) then return false end
    local weapon = client:GetActiveWeapon()
    return IsValid(weapon) and weapon:GetClass() == "lia_adminstick" and weapon.GetActiveMode and weapon:GetActiveMode() == "debug"
end

properties.Add("TogglePropBlacklist", {
    MenuLabel = "Toggle Prop Blacklist",
    Order = 900,
    MenuIcon = "icon16/link.png",
    Filter = function(_, ent, ply)
        local permission = lia.admin.canUseDebugProperties(ply) and IsValid(ent) and ent:GetClass() == "prop_physics" and ply:hasPrivilege("managePropBlacklist")
        lia.debug("[Permissions]", "Permission Check for property TogglePropBlacklist Filter", "entityValid=", tostring(IsValid(ent)), "entityIsPropPhysics=", tostring(IsValid(ent) and ent:GetClass() == "prop_physics" or false), "hasPrivilege(managePropBlacklist)=", tostring(ply:hasPrivilege("managePropBlacklist")), "finalResult=", tostring(permission))
        return permission
    end,
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
            ply:notifySuccess(string.format("Removed from blacklist: %s", model))
        else
            table.insert(list, model)
            lia.data.set("prop_blacklist", list, true, true)
            ply:notifySuccess(string.format("Added to blacklist: %s", model))
        end
    end
})

properties.Add("ToggleCarBlacklist", {
    MenuLabel = "Toggle Car Blacklist",
    Order = 901,
    MenuIcon = "icon16/link.png",
    Filter = function(_, ent, ply)
        local permission = lia.admin.canUseDebugProperties(ply) and IsValid(ent) and (ent:IsVehicle() or ent:isSimfphysCar()) and ply:hasPrivilege("manageVehicleBlacklist")
        lia.debug("[Permissions]", "Permission Check for property ToggleCarBlacklist Filter", "entityValid=", tostring(IsValid(ent)), "entityIsVehicle=", tostring(IsValid(ent) and ent:IsVehicle() or false), "entityIsSimfphysCar=", tostring(IsValid(ent) and ent.isSimfphysCar and ent:isSimfphysCar() or false), "hasPrivilege(manageVehicleBlacklist)=", tostring(ply:hasPrivilege("manageVehicleBlacklist")), "finalResult=", tostring(permission))
        return permission
    end,
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
            ply:notifySuccess(string.format("Removed from blacklist: %s", model))
        else
            table.insert(list, model)
            lia.data.set("carBlacklist", list, true, true)
            ply:notifySuccess(string.format("Added to blacklist: %s", model))
        end
    end
})

properties.Add("copytoclipboard", {
    MenuLabel = "Copy Model to Clipboard",
    Order = 999,
    MenuIcon = "icon16/cup.png",
    Filter = function(_, ent)
        if ent == nil then return false end
        if not IsValid(ent) then return false end
        return lia.admin.canUseDebugProperties(LocalPlayer())
    end,
    Action = function(self, ent)
        self:MsgStart()
        local s = ent:GetModel()
        SetClipboardText(s)
        self:MsgEnd()
    end,
})

properties.Add("CopyBodygroupsByName", {
    MenuLabel = "Copy Bodygroups (Name)",
    Order = 998,
    MenuIcon = "icon16/group.png",
    Filter = function(_, ent)
        if ent == nil then return false end
        if not IsValid(ent) then return false end
        return lia.admin.canUseDebugProperties(LocalPlayer())
    end,
    Action = function(self, ent)
        self:MsgStart()
        local bodygroups = ent:GetBodyGroups()
        local lines = {}
        for _, bg in ipairs(bodygroups) do
            local value = ent:GetBodygroup(bg.id)
            lines[#lines + 1] = bg.name .. " - " .. value
        end

        SetClipboardText(table.concat(lines, "\n"))
        self:MsgEnd()
    end,
})

properties.Add("CopyBodygroupsByID", {
    MenuLabel = "Copy Bodygroups (ID)",
    Order = 997,
    MenuIcon = "icon16/group.png",
    Filter = function(_, ent)
        if ent == nil then return false end
        if not IsValid(ent) then return false end
        return lia.admin.canUseDebugProperties(LocalPlayer())
    end,
    Action = function(self, ent)
        self:MsgStart()
        local bodygroups = ent:GetBodyGroups()
        local lines = {}
        for _, bg in ipairs(bodygroups) do
            local value = ent:GetBodygroup(bg.id)
            lines[#lines + 1] = tostring(bg.id) .. " - " .. value
        end

        SetClipboardText(table.concat(lines, "\n"))
        self:MsgEnd()
    end,
})

properties.Add("CopySkin", {
    MenuLabel = "Copy Skin to Clipboard",
    Order = 996,
    MenuIcon = "icon16/palette.png",
    Filter = function(_, ent)
        if ent == nil then return false end
        if not IsValid(ent) then return false end
        return lia.admin.canUseDebugProperties(LocalPlayer())
    end,
    Action = function(self, ent)
        self:MsgStart()
        SetClipboardText(tostring(ent:GetSkin()))
        self:MsgEnd()
    end,
})

lia.util.setPositionCallback("Faction Spawn Adder", {
    onRun = function(pos, client, typeId)
        if SERVER then
            local factionID = net.ReadString()
            local radius = math.Clamp(net.ReadFloat(), 0, 2048)
            if not factionID or factionID == "" then return end
            local factionInfo = lia.faction.teams[factionID] or lia.util.findFaction(client, factionID)
            if not factionInfo then return end
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                spawns[factionInfo.uniqueID] = spawns[factionInfo.uniqueID] or {}
                table.insert(spawns[factionInfo.uniqueID], {
                    pos = pos,
                    ang = angle_zero,
                    map = game.GetMap(),
                    radius = radius
                })

                lia.module.get("spawns"):StoreSpawns(spawns):next(function() client:notifySuccess(string.format("Sucessfully Added Point")) end)
            end)
        else
            local names, idByDisplay = {}, {}
            for k, v in pairs(lia.faction.teams or {}) do
                local display = tostring(v.name) or v.name or k
                names[#names + 1] = display
                idByDisplay[display] = k
            end

            if #names == 0 then
                client:notifyError(string.format("The specified faction is not valid."))
                return
            end

            lia.derma.requestDropdown("Faction Spawn Adder", names, function(selection)
                if not selection or selection == false then return end
                local factionID = idByDisplay[selection]
                if not factionID then return end
                lia.derma.requestString("Radius", "0 disables the radius.", function(value)
                    if value == false then return end
                    net.Start("liaSetFeaturePosition")
                    net.WriteString("faction_spawn_adder")
                    net.WriteVector(pos)
                    net.WriteString(factionID)
                    net.WriteFloat(math.Clamp(tonumber(value) or 0, 0, 2048))
                    net.SendToServer()
                end, "0")
            end)
        end
    end,
    onSelect = function(client, callback)
        if SERVER then
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                local list = {}
                local curMap = game.GetMap():lower()
                for factionID, factionSpawns in pairs(spawns or {}) do
                    local factionInfo = lia.faction.get(factionID)
                    local label = factionInfo and (factionInfo.name and tostring(factionInfo.name) or factionID) or factionID
                    for i = 1, #(factionSpawns or {}) do
                        local data = factionSpawns[i]
                        local pos = data.pos or data.position
                        if isvector(pos) then
                            local map = data.map and (isstring(data.map) and data.map:lower() or tostring(data.map):lower()) or nil
                            if not map or map == curMap then
                                list[#list + 1] = {
                                    pos = pos,
                                    label = label,
                                    radius = data.radius
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
    onRemove = function(pos, client, typeId)
        lia.module.get("spawns"):FetchSpawns():next(function(spawns)
            local curMap = game.GetMap():lower()
            for factionID, factionSpawns in pairs(spawns) do
                for i = #factionSpawns, 1, -1 do
                    local data = factionSpawns[i]
                    local dpos = data.pos or data.position
                    if isvector(dpos) and dpos:DistToSqr(pos) < 1 then
                        local map = data.map and (isstring(data.map) and data.map:lower() or tostring(data.map):lower()) or nil
                        if not map or map == curMap then
                            table.remove(factionSpawns, i)
                            lia.module.get("spawns"):StoreSpawns(spawns)
                            return
                        end
                    end
                end
            end
        end)
    end,
    color = Color(100, 200, 100),
    serverOnly = true
})

lia.util.setPositionCallback("Class Spawn Adder", {
    onRun = function(pos, client, typeId)
        if SERVER then
            local classID = net.ReadString()
            local radius = math.Clamp(net.ReadFloat(), 0, 2048)
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
                map = game.GetMap(),
                radius = radius
            })

            lia.data.set("spawns", data)
            client:notifySuccess(string.format("Sucessfully Added Point"))
        else
            local names, idByDisplay = {}, {}
            for k, v in pairs(lia.class.list or {}) do
                if isnumber(k) and istable(v) and v.name then
                    local display = v.name or tostring(k)
                    names[#names + 1] = display
                    idByDisplay[display] = tostring(k)
                end
            end

            if #names == 0 then
                client:notifyError(string.format("The specified class is not valid."))
                return
            end

            lia.derma.requestDropdown("Class Spawn Adder", names, function(selection)
                if not selection or selection == false then return end
                local classID = idByDisplay[selection]
                if not classID then return end
                lia.derma.requestString("Radius", "0 disables the radius.", function(value)
                    if value == false then return end
                    net.Start("liaSetFeaturePosition")
                    net.WriteString("class_spawn_adder")
                    net.WriteVector(pos)
                    net.WriteString(classID)
                    net.WriteFloat(math.Clamp(tonumber(value) or 0, 0, 2048))
                    net.SendToServer()
                end, "0")
            end)
        end
    end,
    onSelect = function(client, callback)
        if SERVER then
            local stored = lia.data.get("spawns", {})
            local data = istable(stored) and stored or {}
            local classes = data.classes or {}
            local list = {}
            local curMap = game.GetMap():lower()
            for classID, classSpawns in pairs(classes) do
                local classData = lia.class.get(tonumber(classID))
                local label = classData and (classData.name or tostring(classID)) or tostring(classID)
                for i = 1, #(classSpawns or {}) do
                    local spawnData = classSpawns[i]
                    local pos = spawnData.pos or spawnData.position
                    if isvector(pos) then
                        local map = spawnData.map and (isstring(spawnData.map) and spawnData.map:lower() or tostring(spawnData.map):lower()) or nil
                        if not map or map == curMap then
                            list[#list + 1] = {
                                pos = pos,
                                label = label,
                                radius = spawnData.radius
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
    onRemove = function(pos, client, typeId)
        local stored = lia.data.get("spawns", {})
        local data = istable(stored) and stored or {}
        local classes = data.classes or {}
        local curMap = game.GetMap():lower()
        for classID, classSpawns in pairs(classes) do
            for i = #classSpawns, 1, -1 do
                local spawnData = classSpawns[i]
                local dpos = spawnData.pos or spawnData.position
                if isvector(dpos) and dpos:DistToSqr(pos) < 1 then
                    local map = spawnData.map and (isstring(spawnData.map) and spawnData.map:lower() or tostring(spawnData.map):lower()) or nil
                    if not map or map == curMap then
                        table.remove(classSpawns, i)
                        lia.data.set("spawns", data)
                        return
                    end
                end
            end
        end
    end,
    color = Color(200, 150, 100),
    serverOnly = true
})
