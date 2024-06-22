local GM = GM or GAMEMODE

function GM:SetupQuickMenu(menu)
    local current
    for k, _ in SortedPairs(lia.lang.stored) do
        local name = lia.lang.names[k]
        local name2 = k:sub(1, 1):upper() .. k:sub(2)
        local enabled = LIA_CVAR_LANG:GetString():match(k)
        if name then
            name = name .. " (" .. name2 .. ")"
        else
            name = name2
        end

        local button = menu:addCheck(name, function(panel)
            panel.checked = true
            if IsValid(current) then
                if current == panel then return end
                current.checked = false
            end

            current = panel
            RunConsoleCommand("lia_language", k)
        end, enabled)

        if enabled and not IsValid(current) then current = button end
    end

    menu:addSpacer()
end
