--[[
    Hooks:
        GetMainCharacterID()

    Purpose:
        Allows code to override which character ID should be treated as the player's main character.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("GetMainCharacterID", "liaExampleGetMainCharacterID", function()
            return 15
        end)
        ```

    Returns:
        number|nil
            Return the character ID that should be loaded as the main character.

    Realm:
        Client
]]
--[[
    Hooks:
        OpenCharacterMenuOverride()

    Purpose:
        Allows code to replace the default character menu panel creation.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("OpenCharacterMenuOverride", "liaExampleOpenCharacterMenuOverride", function()
            return true
        end)
        ```

    Returns:
        Panel|boolean|nil
            Return a panel to use instead of the default character menu, or any non-nil value to stop the default menu from opening.

    Realm:
        Client
]]
--[[
    Hooks:
        CanPlayerCreateChar(client, data)

    Purpose:
        Determines whether a player is allowed to create a character with the supplied creation data.

    Category:
        Main Menu

    Parameters:
        client (Player)
            The player attempting to create a character.

        data (table)
            The submitted character creation data.

    Example Usage:
        ```lua
        hook.Add("CanPlayerCreateChar", "liaExampleCanPlayerCreateChar", function(client, data)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block character creation.

    Realm:
        Shared
]]
--[[
    Hooks:
        ChooseCharacter(id)

    Purpose:
        Requests that the client load a specific character from the character list.

    Category:
        Main Menu

    Parameters:
        id (number)
            The character ID to choose.

    Example Usage:
        ```lua
        hook.Add("ChooseCharacter", "liaExampleChooseCharacter", function(id)
            print("[MyModule] handled ChooseCharacter")
        end)
        ```

    Returns:
        Deferred
            Resolves when the character is loaded or rejects with the server-provided error.

    Realm:
        Client
]]
--[[
    Hooks:
        CreateCharacter(data)

    Purpose:
        Validates and submits character-creation payload data to the server.

    Category:
        Main Menu

    Parameters:
        data (table)
            The character field values to validate and send.

    Example Usage:
        ```lua
        hook.Add("CreateCharacter", "liaExampleCreateCharacter", function(data)
            print("[MyModule] handled CreateCharacter")
        end)
        ```

    Returns:
        Deferred
            Resolves with the new character ID or rejects with the validation or server error.

    Realm:
        Client
]]
--[[
    Hooks:
        DeleteCharacter(id)

    Purpose:
        Requests deletion of a character by ID.

    Category:
        Main Menu

    Parameters:
        id (number)
            The character ID to delete.

    Example Usage:
        ```lua
        hook.Add("DeleteCharacter", "liaExampleDeleteCharacter", function(id)
            print("[MyModule] handled DeleteCharacter")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        LoadMainCharacter()

    Purpose:
        Loads the player's configured main character through the normal character-selection flow.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("LoadMainCharacter", "liaExampleLoadMainCharacter", function()
            print("[MyModule] handled LoadMainCharacter")
        end)
        ```

    Returns:
        Deferred|nil
            Returns the character-load deferred when a main character is available.

    Realm:
        Client
]]
--[[
    Hooks:
        GetMaxPlayerChar(client)

    Purpose:
        Returns the total number of character slots available to a player.

    Category:
        Main Menu

    Parameters:
        client (Player)
            The player whose character slot limit should be calculated.

    Example Usage:
        ```lua
        hook.Add("GetMaxPlayerChar", "liaExampleGetMaxPlayerChar", function(client)
            return 15
        end)
        ```

    Returns:
        number
            The maximum number of characters the player may have.

    Realm:
        Shared
]]
--[[
    Hooks:
        OpenCharacterMenu()

    Purpose:
        Opens the default character menu unless another hook overrides it.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("OpenCharacterMenu", "liaExampleOpenCharacterMenu", function()
            print("[MyModule] handled OpenCharacterMenu")
        end)
        ```

    Returns:
        Panel|nil
            The created character panel, when the default menu opens.

    Realm:
        Client
]]
--[[
    Hooks:
        ResetCharacterPanel()

    Purpose:
        Rebuilds the character panel when the current menu state no longer matches the player's session state.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("ResetCharacterPanel", "liaExampleResetCharacterPanel", function()
            print("[MyModule] handled ResetCharacterPanel")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        SetMainCharacter(charID)

    Purpose:
        Sends the selected character ID to the server as the player's main character.

    Category:
        Main Menu

    Parameters:
        charID (number)
            The character ID to store as the player's main character.

    Example Usage:
        ```lua
        hook.Add("SetMainCharacter", "liaExampleSetMainCharacter", function(charID)
            print("[MyModule] handled SetMainCharacter")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        SyncCharList(client)

    Purpose:
        Sends the current character list to a client that is viewing character selection.

    Category:
        Main Menu

    Parameters:
        client (Player)
            The player who should receive the synchronized character list.

    Example Usage:
        ```lua
        hook.Add("SyncCharList", "liaExampleSyncCharList", function(client)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled SyncCharList for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        LiliaLoaded()

    Purpose:
        Opens the character menu after the framework has finished loading on the client.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("LiliaLoaded", "liaExampleLiliaLoaded", function()
            print("[MyModule] handled LiliaLoaded")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        KickedFromChar(characterID, isCurrentChar)

    Purpose:
        Handles the clientside character menu state after the player is kicked from a character.

    Category:
        Main Menu

    Parameters:
        characterID (number)
            The character ID the player was removed from.

        isCurrentChar (boolean)
            Whether the removed character was the player's currently loaded character.

    Example Usage:
        ```lua
        hook.Add("KickedFromChar", "liaExampleKickedFromChar", function(characterID, isCurrentChar)
            print("[MyModule] handled KickedFromChar")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        IsCharacterCreationOverridden()

    Purpose:
        Allows a module or schema to suppress the default character creation flow and supply its own interface.

    Category:
        Main Menu

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("IsCharacterCreationOverridden", "liaExampleIsCharacterCreationOverridden", function()
            return true
        end)
        ```

    Returns:
        boolean|nil
            Return true to prevent the default character creation UI from opening. Return nil or false to keep the built-in flow.

    Realm:
        Client
]]
--[[
    Hooks:
        CharLoaded(Character character)

    Purpose:
        Runs after the client successfully loads a chosen character through the normal character selection flow.

    Category:
        Main Menu

    Parameters:
        character (Character)
            The character object that finished loading on the client.

    Example Usage:
        ```lua
        hook.Add("CharLoaded", "liaExampleCharLoaded", function(character)
            print("[Characters] Loaded:", character:getName())
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        ShouldShowCharVarInCreation(string key)

    Purpose:
        Allows code to hide specific character variable fields from the default creation flow while preserving fallback defaults in the outgoing payload.

    Category:
        Main Menu

    Parameters:
        key (string)
            The character variable key being considered for the creation interface.

    Example Usage:
        ```lua
        hook.Add("ShouldShowCharVarInCreation", "liaExampleShouldShowCharVarInCreation", function(key)
            if key == "desc" then return false end
        end)
        ```

    Returns:
        boolean|nil
            Return false to hide the field from the default creation UI. Return nil or true to leave the field available.

    Realm:
        Client
]]
MODULE.name = "mainMenuModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "mainMenuDescription"
MODULE.NetworkStrings = {"liaMainCharacterSet",}
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
    local function isCharacterCreationOverridden()
        return hook.Run("IsCharacterCreationOverridden") == true
    end

    function MODULE:OpenCharacterMenu()
        local panel = hook.Run("OpenCharacterMenuOverride")
        if panel ~= nil then return panel end
        if isCharacterCreationOverridden() then return end
        return vgui.Create("liaCharacter")
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
        if IsValid(charPanel) and charPanel.isLoadMode and charPanel.availableCharacters and #charPanel.availableCharacters > 0 then return end
        if IsValid(charPanel) then charPanel:Remove() end
        if IsValid(client) and not client:getChar() then self:OpenCharacterMenu() end
    end

    function MODULE:ChooseCharacter(id)
        assert(isnumber(id), L("idMustBeNumber"))
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
                d:reject(message)
            end
        end)

        net.Start("liaCharChoose")
        net.WriteUInt(id, 32)
        net.SendToServer()
        return d
    end

    function MODULE:CreateCharacter(data)
        local client = LocalPlayer()
        assert(istable(data), L("dataMustBeTable"))
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
                if results[1] == false then return d:reject(L(unpack(results, 2))) end
            end

            payload[key] = value
        end

        net.Receive("liaCharCreate", function()
            local id = net.ReadUInt(32)
            local reason = net.ReadString()
            if id > 0 then
                d:resolve(id)
            else
                d:reject(reason)
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
        assert(isnumber(id), L("idMustBeNumber"))
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
            LocalPlayer():notifyErrorLocalized("noMainCharacter")
            return
        end
        return self:ChooseCharacter(mainCharID):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end)
    end

    function MODULE:LiliaLoaded()
        self:OpenCharacterMenu()
    end

    function MODULE:CharListLoaded()
        if IsValid(lia.gui.character) and not lia.gui.character.isLoadMode then lia.gui.character:createStartButton() end
    end

    function MODULE:OnReloaded()
        timer.Simple(0.1, function()
            local client = LocalPlayer()
            if IsValid(client) and not client:getChar() and not IsValid(lia.gui.character) then self:OpenCharacterMenu() end
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
            name = "characters",
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
