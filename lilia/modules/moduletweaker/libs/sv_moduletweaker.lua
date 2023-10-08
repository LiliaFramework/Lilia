--------------------------------------------------------------------------------------------------------
concommand.Add(
    "lia_disablemodule",
    function(client, _, arguments)
        if IsValid(client) and not client:IsSuperAdmin() then return end
        local name = arguments[1]
        local disabled = tobool(arguments[2])
        MODULE:setModuleDisabled(name, disabled)
        local message = name .. " is now " .. (disabled and "disabled" or "enabled")
        if IsValid(client) then
            client:ChatPrint(message)
        end

        print(message)
    end
)
--------------------------------------------------------------------------------------------------------