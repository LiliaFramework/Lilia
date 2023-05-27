local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local vehicleMeta = FindMetaTable("Vehicle")

hook.Add("VerifyDarkRP", "VerifyDarkRP", function()
    DarkRP.formatMoney = function(x) return lia.currency.get .. string.Comma(x) end

    function DarkRP.notify(ply, msgtype, len, msg)
        if type(ply) ~= "table" and not IsValid(ply) then return end
        umsg.Start("_Notify", ply)
        umsg.String(msg)
        umsg.Short(msgtype)
        umsg.Long(len)
        umsg.End()
    end
end)

function playerMeta:canAfford(x)
    return self:getChar():hasMoney(x)
end

function playerMeta:addMoney(x)
    if x < 0 then
        self:getChar():takeMoney(x)
    else
        self:getChar():giveMoney(x)
    end
end

function playerMeta:getDarkRPVar(var)
    if var ~= "money" then
        self:ChatPrint("Tried To Fetch Improper Variable! Please Refer to Our Discord for Help!")

        return
    end

    return self:getChar():getMoney()
end

function vehicleMeta:keysLock()
    self:Fire("lock")
end

function vehicleMeta:keysUnLock()
    self:Fire("unlock")
end