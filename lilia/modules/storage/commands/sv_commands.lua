--------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------
lia.command.add(
    "storagelock",
    {
        privilege = "Lock Storage",
        adminOnly = true,
        syntax = "[string password]",
        onRun = function(client, arguments)
            local ent = client:GetTracedEntity()
            if ent and ent:IsValid() then
                local password = table.concat(arguments, " ")
                if password ~= "" then
                    ent:setNetVar("locked", true)
                    ent.password = password
                    client:notifyLocalized("storPass", password)
                else
                    ent:setNetVar("locked", nil)
                    ent.password = nil
                    client:notifyLocalized("storPassRmv")
                end

                MODULE:saveStorage()
            else
                client:notifyLocalized("invalid", "Entity")
            end
        end
    }
)
--------------------------------------------------------------------------------------------------------