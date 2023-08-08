--------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character or {}
--------------------------------------------------------------------------------------------------------
charMeta.__index = charMeta
charMeta.id = charMeta.id or 0
charMeta.vars = charMeta.vars or {}
debug.getregistry().Character = lia.meta.character
--------------------------------------------------------------------------------------------------------
function charMeta:__tostring()
    return "character[" .. (self.id or 0) .. "]"
end
--------------------------------------------------------------------------------------------------------
function charMeta:__eq(other)
    return self:getID() == other:getID()
end
--------------------------------------------------------------------------------------------------------
function charMeta:getID()
    return self.id
end
--------------------------------------------------------------------------------------------------------
function charMeta:getPlayer()
    if IsValid(self.player) then
        return self.player
    elseif self.steamID then
        local steamID = self.steamID

        for k, v in ipairs(player.GetAll()) do
            if v:SteamID64() == steamID then
                self.player = v

                return v
            end
        end
    else
        for k, v in ipairs(player.GetAll()) do
            local char = v:getChar()

            if char and (char:getID() == self:getID()) then
                self.player = v

                return v
            end
        end
    end
end
--------------------------------------------------------------------------------------------------------
function charMeta:hasMoney(amount)
    if amount < 0 then
        print("Negative Money Check Received.")
    end

    return self:getMoney() >= amount
end
--------------------------------------------------------------------------------------------------------
function charMeta:giveMoney(amount, takingMoney)
    if not takingMoney then end
    self:setMoney(self:getMoney() + amount)

    return true
end
--------------------------------------------------------------------------------------------------------
function charMeta:takeMoney(amount)
    amount = math.abs(amount)
    self:giveMoney(-amount, true)

    return true
end
--------------------------------------------------------------------------------------------------------
function lia.char.registerVar(key, data)
    lia.char.vars[key] = data
    data.index = data.index or table.Count(lia.char.vars)
    local upperName = key:sub(1, 1):upper() .. key:sub(2)

    if SERVER and not data.isNotModifiable then
        if data.onSet then
            charMeta["set" .. upperName] = data.onSet
        elseif data.noNetworking then
            charMeta["set" .. upperName] = function(self, value)
                self.vars[key] = value
            end
        elseif data.isLocal then
            charMeta["set" .. upperName] = function(self, value)
                local curChar = self:getPlayer() and self:getPlayer():getChar()
                local sendID = true

                if curChar and curChar == self then
                    sendID = false
                end

                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(self.player, "charSet", key, value, sendID and self:getID() or nil)
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        else
            charMeta["set" .. upperName] = function(self, value)
                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(nil, "charSet", key, value, self:getID())
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        end
    end

    if data.onGet then
        charMeta["get" .. upperName] = data.onGet
    else
        charMeta["get" .. upperName] = function(self, default)
            local value = self.vars[key]
            if value ~= nil then return value end
            if default == nil then return lia.char.vars[key] and lia.char.vars[key].default or nil end

            return default
        end
    end

    charMeta.vars[key] = data.default
end
--------------------------------------------------------------------------------------------------------
function charMeta:getFlags()
    return self:getData("f", "")
end
--------------------------------------------------------------------------------------------------------
function charMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end

    return hook.Run("CharacterFlagCheck", self, flags) or false
end
--------------------------------------------------------------------------------------------------------
lia.util.include("core/libs/meta/character/sv_character.lua")
--------------------------------------------------------------------------------------------------------
lia.meta.character = charMeta
--------------------------------------------------------------------------------------------------------