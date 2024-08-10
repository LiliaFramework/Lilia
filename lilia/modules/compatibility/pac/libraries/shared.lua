local playerMeta = FindMetaTable("Player")
function MODULE:setupPACDataFromItems()
    for itemType, item in pairs(lia.item.list) do
        if istable(item.pacData) then self.partData[itemType] = item.pacData end
    end
end

function MODULE:InitializedModules()
    if CLIENT then hook.Remove("HUDPaint", "pac_in_editor") end
    timer.Simple(1, function() self:setupPACDataFromItems() end)
end

function MODULE:isAllowedToUsePAC(client)
    local character = client:getChar()
    return character and (client:HasPrivilege("Staff Permissions - Can Use PAC3") or character:hasFlags("P"))
end

function MODULE:CanWearParts(client)
    return self:isAllowedToUsePAC(client)
end

function MODULE:PrePACEditorOpen(client)
    return self:isAllowedToUsePAC(client)
end

function MODULE:PrePACConfigApply(client)
    return self:isAllowedToUsePAC(client)
end

function MODULE:TryViewModel(entity)
    return entity == pac.LocalPlayer:GetViewModel() and pac.LocalPlayer or entity
end

function MODULE:PAC3RegisterEvents()
    local events = {
        {
            name = "weapon_raised",
            args = {},
            available = function() return playerMeta.isWepRaised ~= nil end,
            func = function(_, _, entity)
                entity = self:TryViewModel(entity)
                return entity.isWepRaised and entity:isWepRaised() or false
            end
        }
    }

    for _, v in ipairs(events) do
        local available = v.available
        local eventObject = pac.CreateEvent(v.name, v.args)
        eventObject.Think = v.func
        function eventObject:IsAvailable()
            return available()
        end

        pac.RegisterEvent(eventObject)
    end
end

lia.flag.add("P", "Access to PAC3.")