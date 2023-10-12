--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharChoose")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharCreate")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharDelete")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharList")
--------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharMenu")
--------------------------------------------------------------------------------------------------------------------------
function MODULE:syncCharList(client)
    if not client.liaCharList then return end
    net.Start("liaCharList")
    net.WriteUInt(#client.liaCharList, 32)
    for i = 1, #client.liaCharList do
        net.WriteUInt(client.liaCharList[i], 32)
    end

    net.Send(client)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerCreateCharacter(client)
    local count = #client.liaCharList
    local maxChars = hook.Run("GetMaxPlayerCharacter", client) or lia.config.MaxCharacters
    if count >= maxChars then return false end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerLiliaDataLoaded(client)
    lia.char.restore(
        client,
        function(charList)
            if not IsValid(client) then return end
            MsgN("Loaded (" .. table.concat(charList, ", ") .. ") for " .. client:Name())
            for k, v in ipairs(charList) do
                if lia.char.loaded[v] then
                    lia.char.loaded[v]:sync(client)
                end
            end

            for k, v in ipairs(player.GetAll()) do
                if v:getChar() then
                    v:getChar():sync(client)
                end
            end

            client.liaCharList = charList
            self:syncCharList(client)
            client.liaLoaded = true
            client:setLiliaData("intro", true)
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PostPlayerInitialSpawn(client)
    client:SetNoDraw(true)
    client:SetNotSolid(true)
    client:Lock()
    timer.Simple(
        1,
        function()
            if not IsValid(client) then return end
            client:KillSilent()
            client:StripAmmo()
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerUseChar(client, character, oldCharacter)
    if client:getChar() and client:getChar():getID() == character:getID() then return false, "@usingChar" end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerLoadedChar(client, character, oldCharacter)
    client:Spawn()
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:OnCharCreated(client, character)
    local id = character:getID()
    MsgN("Created character '" .. id .. "' for " .. client:steamName() .. ".")
end
--------------------------------------------------------------------------------------------------------------------------