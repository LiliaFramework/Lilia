MODULE.name = "mainMenuModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "mainMenuDescription"
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
    function MODULE:PlayerButtonDown(_, button)
        if button == KEY_ESCAPE and IsValid(lia.gui.menu) and LocalPlayer():getChar() then
            lia.gui.menu:Remove()
            return true
        end
    end

    function MODULE:ResetCharacterPanel()
        local charPanel = lia.gui.character
        if IsValid(charPanel) and charPanel.isLoadMode and charPanel.availableCharacters then return end
        if IsValid(charPanel) then charPanel:Remove() end
        local client = LocalPlayer()
        if IsValid(client) and not client:getChar() then vgui.Create("liaCharacter") end
    end

    function MODULE:ChooseCharacter(id)
        assert(isnumber(id), L("idMustBeNumber"))
        local d = deferred.new()
        net.Receive("liaCharChoose", function()
            local message = net.ReadString()
            if message == "" then
                d:resolve()
                lia.char.getCharacter(id, nil, function(character) hook.Run("CharLoaded", character) end)
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
            if charVar.noDisplay then continue end
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

    function MODULE:LiliaLoaded()
        vgui.Create("liaCharacter")
    end

    function MODULE:KickedFromChar(_, isCurrentChar)
        if isCurrentChar then
            local charPanel = vgui.Create("liaCharacter")
            charPanel.isKickedFromChar = true
        end
    end

    function MODULE:CreateMenuButtons(tabs)
        tabs["characters"] = function()
            local client = LocalPlayer()
            if client:isInThirdPerson() then
                lia.option.set("thirdPersonEnabled", false)
                hook.Run("ThirdPersonToggled", false)
            end

            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            vgui.Create("liaCharacter")
        end
    end

    net.Receive("liaStaffDiscordPrompt", function()
        lia.derma.requestString(L("staffCharacterSetup"), L("discordUsernamePrompt"), function(discord)
            if discord and discord:Trim() ~= "" then
                net.Start("liaStaffDiscordResponse")
                net.WriteString(discord:Trim())
                net.SendToServer()
            elseif discord == false then
                net.Start("liaStaffDiscordResponse")
                net.WriteString("not provided")
                net.SendToServer()
            else
                LocalPlayer():notifyErrorLocalized("discordUsernameEmpty")
            end
        end, "", nil)
    end)
end

function MODULE:CanPlayerCreateChar(client, data)
    local isStaffCharacter = istable(data) and data.faction == FACTION_STAFF
    if isStaffCharacter then return true end
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
    if SERVER then
        local staffCount = 0
        for _, charID in pairs(client.liaCharList or {}) do
            local character = lia.char.getCharacter(charID)
            if character and character:getFaction() == FACTION_STAFF then staffCount = staffCount + 1 end
        end
        return maxChars + staffCount
    else
        local staffCount = 0
        for _, charID in pairs(lia.characters or {}) do
            local character = lia.char.getCharacter(charID)
            if character and character:getFaction() == FACTION_STAFF then staffCount = staffCount + 1 end
        end
        return maxChars + staffCount
    end
end
