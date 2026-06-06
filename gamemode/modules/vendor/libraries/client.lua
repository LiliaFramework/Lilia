function MODULE:VendorOpened(vendor)
    local vendorUI = vgui.Create("liaVendor")
    vendorUI.vendor = vendor
    hook.Run("OnOpenVendorMenu", self, vendor)
end

function MODULE:VendorExited()
    if IsValid(lia.gui.vendor) then lia.gui.vendor:Remove() end
end

function MODULE:AddToAdminStickHUD(client, target, information)
    if not IsValid(target) or not target.IsVendor then return end
    local name = target:getName()
    if name and name ~= "" then table.insert(information, L("vendorNameLabel") .. name) end
    local animation = lia.vendor.getVendorProperty(target, "animation")
    if animation and animation ~= "" then table.insert(information, L("animation") .. ":" .. animation) end
    local itemCount = 0
    if target.items then
        for _, itemData in pairs(target.items) do
            if itemData[VENDOR_STOCK] and itemData[VENDOR_STOCK] > 0 then itemCount = itemCount + 1 end
        end
    end

    table.insert(information, L("vendorItemCount") .. ": " .. itemCount)
    local factionNames = {}
    if target.factions then
        for factionID, _ in pairs(target.factions) do
            local faction = lia.faction.indices[factionID]
            if faction then table.insert(factionNames, faction.name) end
        end
    end

    if #factionNames > 0 then
        table.insert(information, L("allowedFactions") .. ":")
        for _, factionName in ipairs(factionNames) do
            table.insert(information, "- " .. factionName)
        end

        table.insert(information, "")
    else
        table.insert(information, L("allFactionsLabel"))
    end

    local classNames = {}
    if target.classes then
        for classID, _ in pairs(target.classes) do
            local class = lia.class.list[classID]
            if class then table.insert(classNames, class.name) end
        end
    end

    if #classNames > 0 then
        table.insert(information, L("allowedClasses") .. ":")
        for _, className in ipairs(classNames) do
            table.insert(information, "- " .. className)
        end
    end
end
