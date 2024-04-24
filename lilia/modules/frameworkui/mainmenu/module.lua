--[[--

**Configuration Values:**.

- **MusicVolume**: Set Music Volume on Main Menu | **float**.

- **Music**: Set Main Menu Background Music | **string**.

- **LogoURL**: Set Main Menu Logo | **string**.

- **BackgroundURL**: Set Background Image URL (if applicable) | **string**.

- **BackgroundIsYoutubeVideo**: Set If Background Screen is a YT video | **bool**.

- **CharMenuBGInputDisabled**: Disable Background Input during Main Menu Lookup | **bool**.

- **CharCreationTransparentBackground**: Set Transparent Background during Character Creation | **bool**.
]]
-- @configurations MainMenu
MODULE.name = "Framework UI - Main Menu"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Adds a Main Menu that allows to access several characters options."
MODULE.identifier = "MainMenu"
if SERVER then
    function MODULE:syncCharList(client)
        if not client.liaCharList then return end
        net.Start("liaCharList")
        net.WriteUInt(#client.liaCharList, 32)
        for i = 1, #client.liaCharList do
            net.WriteUInt(client.liaCharList[i], 32)
        end

        net.Send(client)
    end

    function MODULE:CanPlayerCreateCharacter(client)
        local count = #client.liaCharList or 0
        local maxChars = hook.Run("GetMaxPlayerCharacter", client) or lia.config.MaxCharacters
        if (count or 0) >= maxChars then return false end
    end
else
    function MODULE:chooseCharacter(id)
        assert(isnumber(id), "id must be a number")
        local d = deferred.new()
        net.Receive("liaCharChoose", function()
            local message = net.ReadString()
            if message == "" then
                d:resolve()
                hook.Run("CharLoaded", lia.char.loaded[id])
            else
                d:reject(message)
            end
        end)

        net.Start("liaCharChoose")
        net.WriteUInt(id, 32)
        net.SendToServer()
        return d
    end

    function MODULE:createCharacter(data)
        assert(istable(data), "data must be a table")
        local d = deferred.new()
        local payload = {}
        for key, charVar in pairs(lia.char.vars) do
            if charVar.noDisplay then continue end
            local value = data[key]
            if isfunction(charVar.onValidate) then
                local results = {charVar.onValidate(value, data, LocalPlayer())}
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

    function MODULE:deleteCharacter(id)
        assert(isnumber(id), "id must be a number")
        net.Start("liaCharDelete")
        net.WriteUInt(id, 32)
        net.SendToServer()
    end
end
