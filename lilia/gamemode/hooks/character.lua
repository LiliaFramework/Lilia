local GM = GM or GAMEMODE
function GM:GetMaxPlayerCharacter(client)
    LiliaDeprecated("GetMaxPlayerCharacter is deprecated. Use GetMaxPlayerChar for optimization purposes.")
    hook.Run("GetMaxPlayerChar", client)
end

function GM:CanPlayerCreateCharacter(client)
    LiliaDeprecated("CanPlayerCreateChar is deprecated. Use CanPlayerCreateChar for optimization purposes.")
    hook.Run("CanPlayerCreateChar", client)
end

if SERVER then
    function GM:onCharCreated(client, character, data)
        LiliaDeprecated("onCharCreated is deprecated. Use OnCharCreated for optimization purposes.")
        hook.Run("OnCharCreated", client, character, data)
    end

    function GM:OnCharCreated(client, character)
        local permFlags = client:getPermFlags()
        if permFlags and #permFlags > 0 then character:giveFlags(permFlags) end
    end

    function GM:onTransferred(client)
        LiliaDeprecated("onTransferred is deprecated. Use OnTransferred for optimization purposes.")
        hook.Run("OnTransferred", client)
    end

    function GM:CharacterPreSave(character)
        LiliaDeprecated("CharacterPreSave is deprecated. Use CharPreSave for optimization purposes.")
        hook.Run("CharPreSave", character)
    end

    function GM:CharPreSave(character)
        local client = character:getPlayer()
        if not character:getInv() then return end
        for _, v in pairs(character:getInv():getItems()) do
            if v.onSave then v:call("onSave", client) end
        end
    end

    function GM:PlayerLoadedChar(client, character, lastChar)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.updateTable({
            _lastJoinTime = timeStamp
        }, nil, "characters", "_id = " .. character:getID())

        if lastChar then
            local charEnts = lastChar:getVar("charEnts") or {}
            for _, v in ipairs(charEnts) do
                if v and IsValid(v) then v:Remove() end
            end

            lastChar:setVar("charEnts", nil)
        end

        if client:hasRagdoll() then
            local ragdoll = client:getRagdoll()
            ragdoll.liaNoReset = true
            ragdoll.liaIgnoreDelete = true
            ragdoll:Remove()
        end

        character:setData("loginTime", os.time())
        if lia.config.ServerWorkshop ~= "" and not client:getLiliaData("workshopRequested") then
            net.Start("RequestServerContent")
            net.Send(client)
            client:setLiliaData("workshopRequested", true)
        end

        hook.Run("PlayerLoadout", client)
    end

    function GM:CharacterLoaded(id)
        LiliaDeprecated("CharacterLoaded is deprecated. Use CharLoaded for optimization purposes.")
        hook.Run("CharLoaded", id)
    end

    function GM:PreCharacterDelete(id)
        LiliaDeprecated("PreCharacterDelete is deprecated. Use PreCharDelete for optimization purposes.")
        hook.Run("PreCharDelete", id)
    end

    function GM:OnCharacterDelete(client, id)
        LiliaDeprecated("OnCharacterDelete is deprecated. Use OnCharDelete for optimization purposes.")
        hook.Run("OnCharDelete", client, id)
    end

    function GM:CharLoaded(id)
        local character = lia.char.loaded[id]
        if character then
            local client = character:getPlayer()
            if IsValid(client) then
                local uniqueID = "liaSaveChar" .. client:SteamID()
                timer.Create(uniqueID, lia.config.CharacterDataSaveInterval, 0, function()
                    if IsValid(client) and client:getChar() then
                        client:getChar():save()
                    else
                        timer.Remove(uniqueID)
                    end
                end)
            end
        end
    end

    function GM:PrePlayerLoadedChar(client)
        client:SetBodyGroups("000000000")
        client:SetSkin(0)
        client:ExitVehicle()
        client:Freeze(false)
    end
else
    function GM:CanDisplayCharacterInfo(client, id)
        LiliaDeprecated("CanDisplayCharacterInfo is deprecated. Use CanDisplayCharInfo for optimization purposes.")
        hook.Run("CanDisplayCharInfo", client, id)
    end

    function GM:KickedFromCharacter(id, isCurrentChar)
        LiliaDeprecated("KickedFromCharacter is deprecated. Use KickedFromChar for optimization purposes.")
        hook.Run("KickedFromChar", id, isCurrentChar)
    end

    function GM:CharacterListLoaded(newCharList)
        LiliaDeprecated("CharacterListLoaded is deprecated. Use CharListLoaded for optimization purposes.")
        hook.Run("CharListLoaded", newCharList)
    end

    function GM:CharacterListUpdated(oldCharList, newCharList)
        LiliaDeprecated("CharacterListUpdated is deprecated. Use CharListUpdated for optimization purposes.")
        hook.Run("CharListUpdated", oldCharList, newCharList)
    end

    function GM:CharListLoaded()
        timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
            local client = LocalPlayer()
            if not IsValid(client) then return end
            timer.Remove("liaWaitUntilPlayerValid")
            hook.Run("LiliaLoaded")
        end)
    end
end