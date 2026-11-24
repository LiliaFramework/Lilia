MODULE.name = "Main Menu"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Creates the in-game main menu used for selecting, creating, and managing player characters before entering the world."
MODULE.NetworkStrings = {"liaMainCharacterSet", "liaSetMainCharacter", "liaStaffDiscordPrompt",}
if SERVER then
    function MODULE:SyncCharList(client)
        if not client.liaCharList then return end
        net.Start("liaCharList")
        net.WriteUInt(#client.liaCharList, 32)
        for i = 1, #client.liaCharList do
            net.WriteUInt(client.liaCharList[i], 32)
        end

        net.Send(client)
    end
else
    function MODULE:OpenCharacterMenu()
        local panel = hook.Run("OpenCharacterMenuOverride")
        if panel ~= nil then return panel end
        if hook.Run("IsCharacterCreationOverridden") == true then return end
        local creator = lia.gui.schemaCharacterCreator
        if IsValid(creator) then return IsValid(creator.sourceMenu) and creator.sourceMenu or creator end
        return vgui.Create("liaCharacter")
    end

    function MODULE:OpenCharacterCreator(sourceMenu)
        local creator = lia.gui.schemaCharacterCreator
        if IsValid(creator) then
            if IsValid(sourceMenu) and not IsValid(creator.sourceMenu) then creator:SetSourceMenu(sourceMenu) end
            return creator
        end

        local client = LocalPlayer()
        if not IsValid(client) then return nil, "Character creation is not available yet." end
        local allowed, reason = hook.Run("CanPlayerCreateChar", client)
        if allowed == false then return nil, reason or "You cannot create another character." end
        allowed, reason = hook.Run("ShouldMenuButtonShow", "create")
        if allowed == false then return nil, reason or "Character creation is unavailable." end
        if not vgui.GetControlTable("liaSchemaCharacterCreator") then return nil, "The character creator interface is unavailable." end
        creator = vgui.Create("liaSchemaCharacterCreator")
        if not IsValid(creator) then return nil, "Failed to open the character creator." end
        if IsValid(sourceMenu) then creator:SetSourceMenu(sourceMenu) end
        return creator
    end

    function MODULE:PlayerButtonDown(_, button)
        if button == KEY_ESCAPE and IsValid(lia.gui.menu) and LocalPlayer():getChar() then
            lia.gui.menu:Remove()
            return true
        end
    end

    function MODULE:ResetCharacterPanel()
        local charPanel = lia.gui.character
        local client = LocalPlayer()
        if IsValid(lia.gui.schemaCharacterCreator) then return end
        if IsValid(charPanel) and charPanel.inCharacterCreation then return end
        if IsValid(charPanel) and charPanel.isLoadMode and charPanel.availableCharacters and #charPanel.availableCharacters > 0 then return end
        if IsValid(charPanel) then charPanel:Remove() end
        if IsValid(client) and not client:getChar() then self:OpenCharacterMenu() end
    end

    function MODULE:GetMainMenuPosition(character)
        if not character then return nil, nil end
        if lia.config.get("MainMenuUseLastPos", true) then
            local lastPos = character:getLastPos()
            if lastPos then
                local pos = lastPos.pos or lastPos.position or lastPos.Pos or lastPos.Position
                local ang = lastPos.ang or lastPos.angles or lastPos.Ang or lastPos.Angles
                if pos and isvector(pos) then
                    local angles = ang and isangle(ang) and ang or Angle(0, 0, 0)
                    return pos, angles
                end
            end

            local client = LocalPlayer()
            if IsValid(client) and client:getChar() then
                local currentChar = client:getChar()
                local currentCharID = currentChar.getID and currentChar:getID() or nil
                local viewingCharID = character.getID and character:getID() or nil
                if currentCharID == viewingCharID then return client:GetPos(), Angle(0, 0, 0) end
            end
        end

        if character:getFaction() then
            local faction = lia.faction.get(character:getFaction())
            if faction and faction.mainMenuPosition then
                local menuPos = faction.mainMenuPosition
                local currentMap = game.GetMap()
                if istable(menuPos) and menuPos[currentMap] then
                    local mapPos = menuPos[currentMap]
                    if istable(mapPos) then
                        return mapPos.position, mapPos.angles
                    elseif isvector(mapPos) then
                        return mapPos, Angle(0, 0, 0)
                    end
                end

                if istable(menuPos) then
                    return menuPos.position, menuPos.angles
                elseif isvector(menuPos) then
                    return menuPos, Angle(0, 0, 0)
                end
            end
        end
    end

    function MODULE:ChooseCharacter(id)
        assert(isnumber(id), "id must be a number")
        local d = deferred.new()
        net.Receive("liaCharChoose", function()
            local message = net.ReadString()
            if message == "" then
                d:resolve()
                lia.char.getCharacter(id, nil, function(character)
                    local client = LocalPlayer()
                    if IsValid(client) then client:SetNoDraw(false) end
                    hook.Run("CharLoaded", character)
                end)
            else
                d:reject(lia.lang.resolve(message))
            end
        end)

        net.Start("liaCharChoose")
        net.WriteUInt(id, 32)
        net.SendToServer()
        return d
    end

    function MODULE:CreateCharacter(data)
        local client = LocalPlayer()
        assert(istable(data), "Data must be a table")
        local d = deferred.new()
        local payload = {}
        for key, charVar in pairs(lia.char.vars) do
            if charVar.noDisplay and not isfunction(charVar.onValidate) then continue end
            if hook.Run("ShouldShowCharVarInCreation", key) == false then
                local value = charVar.default
                if istable(value) then value = table.Copy(value) end
                payload[key] = value
                continue
            end

            local value = data[key]
            if isfunction(charVar.onValidate) then
                local results = {charVar.onValidate(value, data, client)}
                if results[1] == false then return d:reject(tostring(unpack(results, 2))) end
            end

            payload[key] = value
        end

        net.Receive("liaCharCreate", function()
            local id = net.ReadUInt(32)
            local reason = net.ReadString()
            if id > 0 then
                d:resolve(id)
            else
                d:reject(tostring(reason))
            end
        end)

        net.Start("liaCharCreate")
        net.WriteUInt(table.Count(payload), 32)
        for key, value in pairs(payload) do
            net.WriteString(key)
            net.WriteType(value)
        end

        net.SendToServer()
        return d
    end

    function MODULE:DeleteCharacter(id)
        assert(isnumber(id), "id must be a number")
        net.Start("liaCharDelete")
        net.WriteUInt(id, 32)
        net.SendToServer()
    end

    function MODULE:GetMainCharacterID()
        local client = LocalPlayer()
        if IsValid(client) then
            local mainCharID = client:getMainCharacter()
            return mainCharID and tonumber(mainCharID) or nil
        end
        return nil
    end

    function MODULE:SetMainCharacter(charID)
        net.Start("liaSetMainCharacter")
        net.WriteUInt(charID or 0, 32)
        net.SendToServer()
    end

    function MODULE:LoadMainCharacter()
        local mainCharID = hook.Run("GetMainCharacterID")
        if not mainCharID then
            LocalPlayer():notifyError(string.format("No main character set."))
            return
        end
        return self:ChooseCharacter(mainCharID):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end)
    end

    function MODULE:LiliaLoaded()
        if not IsValid(LocalPlayer()) or LocalPlayer():getChar() then return end
        self:OpenCharacterMenu()
    end

    function MODULE:CharListLoaded()
        if IsValid(lia.gui.character) and not lia.gui.character.isLoadMode and not lia.gui.character.inCharacterCreation then lia.gui.character:createStartButton() end
    end

    function MODULE:OnReloaded()
        timer.Simple(0.1, function()
            local client = LocalPlayer()
            if IsValid(client) and not client:getChar() and not IsValid(lia.gui.character) and not IsValid(lia.gui.schemaCharacterCreator) then self:OpenCharacterMenu() end
        end)
    end

    function MODULE:KickedFromChar(characterID, isCurrentChar)
        if isCurrentChar then
            local charPanel = self:OpenCharacterMenu()
            if IsValid(charPanel) then charPanel.isKickedFromChar = true end
        end
    end

    local function isInThirdPerson()
        local thirdPersonEnabled = lia.config.get("ThirdPersonEnabled", true)
        local tpEnabled = lia.option.get("thirdPersonEnabled", false)
        return tpEnabled and thirdPersonEnabled
    end

    function MODULE:CreateMenuButtons(tabs)
        tabs["characters"] = {
            name = "Characters",
            icon = "icon16/user.png",
            func = function()
                if isInThirdPerson() then
                    lia.option.set("thirdPersonEnabled", false)
                    hook.Run("ThirdPersonToggled", false)
                end

                if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
                lia.module.get("mainmenu"):OpenCharacterMenu()
            end
        }
    end
end

function MODULE:CanPlayerCreateChar(client, data)
    if istable(data) and data.faction == FACTION_STAFF then return true end
    if SERVER then
        local count = #client.liaCharList or 0
        local maxChars = hook.Run("GetMaxPlayerChar", client) or lia.config.get("MaxCharacters")
        if (count or 0) >= maxChars then return false end
        return true
    else
        local count = #lia.characters or 0
        local maxChars = hook.Run("GetMaxPlayerChar", client) or lia.config.get("MaxCharacters")
        if (count or 0) >= maxChars then return false end
    end
end

function MODULE:GetMaxPlayerChar(client)
    local maxChars = lia.config.get("MaxCharacters")
    local extraChars = client:getLiliaData("extraCharacters", 0) or 0
    if SERVER then
        local staffCount = 0
        for _, charID in pairs(client.liaCharList or {}) do
            local character = lia.char.getCharacter(charID)
            if character and character:getFaction() == FACTION_STAFF then staffCount = staffCount + 1 end
        end
        return maxChars + staffCount + extraChars
    else
        local staffCount = 0
        for _, charID in pairs(lia.characters or {}) do
            local character = lia.char.getCharacter(charID)
            if character and character:getFaction() == FACTION_STAFF then staffCount = staffCount + 1 end
        end
        return maxChars + staffCount + extraChars
    end
end

MODULE.creationTabs = MODULE.creationTabs or {}
MODULE.creationContext = MODULE.creationContext or {}
function MODULE:RefreshCreationTabs()
    local tabs = {}
    hook.Run("RegisterCharacterCreationTabs", tabs, self)
    self.creationTabs = {}
    for id, data in pairs(tabs) do
        if not isstring(id) or id == "" then continue end
        if not istable(data) or not isstring(data.name) or not isfunction(data.onCreate) then continue end
        data.id = id
        data.order = tonumber(data.order) or 100
        self.creationTabs[id] = data
    end
    return self.creationTabs
end

function MODULE:GetCreationTabs()
    local tabs = {}
    for _, tab in pairs(self.creationTabs) do
        tabs[#tabs + 1] = tab
    end

    table.sort(tabs, function(a, b)
        if a.order == b.order then return a.id < b.id end
        return a.order < b.order
    end)
    return tabs
end

function MODULE:GetCreationContext()
    return self.creationContext
end

function MODULE:SetCreationContext(key, value)
    self.creationContext[key] = value
end

local function getCreationFactionIndex(value)
    local index = tonumber(value)
    if index and lia.faction and lia.faction.indices and lia.faction.indices[index] then return index end
    local faction = lia.faction.get(value)
    if faction then return faction.index end
end

local function getValidDefaultCreationClass(value, factionValue)
    local index = tonumber(value)
    if not index or index <= 0 or not lia.class or not lia.class.list then return nil end
    local class = lia.class.list[index]
    local factionIndex = getCreationFactionIndex(factionValue)
    if not class or not factionIndex or class.faction ~= factionIndex or not class.isDefault then return nil end
    return class
end

local function installCreationClassValidation()
    local classVar = lia.char and lia.char.vars and lia.char.vars.class
    if not classVar or classVar.schemaCreatorClassValidation then return end
    local previousValidate = classVar.onValidate
    classVar.onValidate = function(value, data, client)
        if isfunction(previousValidate) then
            local result = {previousValidate(value, data, client)}
            if result[1] == false then return unpack(result) end
        end

        if value == nil or tonumber(value) == 0 then return true end
        if not getValidDefaultCreationClass(value, data and data.faction) then return false, "Invalid class." end
        return true
    end

    classVar.schemaCreatorClassValidation = true
end

installCreationClassValidation()
hook.Add("PostGamemodeLoaded", "liaMainMenuInstallCreationClassValidation", installCreationClassValidation)
hook.Add("OverrideFactionModelCustomization", "liaMainMenuCreatorClassModelCustomization", function(_, faction, context, skinAllowed, bodygroupsAllowed)
    if not faction or not istable(context) then return end
    local classIndex = tonumber(context.class)
    local class = classIndex and lia.class and lia.class.list and lia.class.list[classIndex] or nil
    if class and class.faction == faction.index then
        if class.skinAllowed ~= nil then skinAllowed = class.skinAllowed == true end
        if class.bodygroupsAllowed ~= nil then bodygroupsAllowed = class.bodygroupsAllowed == true end
        if istable(class.allowedSkins) then skinAllowed = true end
        if istable(class.allowedBodygroups) then bodygroupsAllowed = true end
    end

    if istable(faction.allowedSkins) then skinAllowed = true end
    if istable(faction.allowedBodygroups) then bodygroupsAllowed = true end
    local creationClass = lia.faction.getCharacterCreationClass(faction, context.class)
    local modelData = lia.faction.getCharacterCreationModelInfo(faction, creationClass, context.model)
    local parsed = modelData and lia.faction.getModelData(context.model or 1, modelData) or nil
    if parsed then
        if istable(parsed.allowedSkins) then skinAllowed = true end
        if istable(parsed.allowedBodygroups) then bodygroupsAllowed = true end
    end
    return skinAllowed, bodygroupsAllowed
end)

if SERVER then
    hook.Add("OnCharCreated", "liaMainMenuApplyCreationClass", function(client, character, originalData)
        local class = getValidDefaultCreationClass(originalData and originalData.class, originalData and originalData.faction)
        if not class or not character then return end
        timer.Simple(0.4, function()
            if not character or not character.getClass or not character.setClass then return end
            local oldClass = character:getClass()
            if oldClass == class.index then return end
            character:setClass(class.index)
            if IsValid(client) then
                hook.Run("OnPlayerJoinClass", client, class.index, oldClass)
                if character.sync then character:sync(client) end
            end

            if character.save then character:save() end
        end)
    end)
end
