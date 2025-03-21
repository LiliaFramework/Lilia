local characterMeta = lia.meta.character or {}
function characterMeta:hasClassWhitelist(class)
    local wl = self:getData("whitelist", {})
    return wl[class] ~= nil
end

function characterMeta:isFaction(faction)
    return self:getChar():getFaction() == faction
end

function characterMeta:isClass(class)
    return self:getChar():getClass() == class
end

if SERVER then
    function characterMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if not lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    function characterMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    function characterMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    function characterMeta:classWhitelist(class)
        local wl = self:getData("whitelist", {})
        wl[class] = true
        self:setData("whitelist", wl)
    end

    function characterMeta:classUnWhitelist(class)
        local wl = self:getData("whitelist", {})
        wl[class] = false
        self:setData("whitelist", wl)
    end

    function characterMeta:joinClass(class, isForced)
        if not class then
            self:kickClass()
            return false
        end

        local client = self:getPlayer()
        local classData = lia.class.list[class]
        if not classData or classData.faction ~= client:Team() then
            self:KickClass()
            return false
        end

        local oldClass = self:getClass()
        local hadOldClass = oldClass and oldClass ~= -1
        if isForced or lia.class.canBe(client, class) then
            self:setClass(class)
            if lia.config.get("PermaClass", true) then self:setData("pclass", class) end
            if hadOldClass then
                hook.Run("OnPlayerSwitchClass", client, class, oldClass)
            else
                hook.Run("OnPlayerJoinClass", client, class, oldClass)
            end
            return true
        else
            return false
        end
    end

    function characterMeta:kickClass()
        local client = self:getPlayer()
        if not client then return end
        local validDefaultClass
        for k, v in pairs(lia.class.list) do
            if v.faction == client:Team() and v.isDefault then
                validDefaultClass = k
                break
            end
        end

        if validDefaultClass then
            self:joinClass(validDefaultClass)
            hook.Run("OnPlayerJoinClass", client, validDefaultClass)
        else
            self:setClass(nil)
        end
    end
end