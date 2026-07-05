--[[
    Hooks:
        VendorOpened(Entity vendor)

    Purpose:
        Runs on the client when vendor access succeeds and the vendor interface is about to be shown for the received vendor entity.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The vendor entity whose menu is being opened.

    Example Usage:
        ```lua
        hook.Add("VendorOpened", "liaExampleVendorOpened", function(vendor)
            if IsValid(vendor) then
                print("Opened vendor:", vendor:getNetVar("name", vendor:GetClass()))
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        OnOpenVendorMenu(table moduleTable, Entity vendor)

    Purpose:
        Runs after the vendor menu panel is created and assigned to the received vendor so client code can adjust the active UI.

    Category:
        Vendor

    Parameters:
        moduleTable (table)
            The vendor module table that opened the menu and dispatched the hook.

        vendor (Entity)
            The vendor entity assigned to the active vendor panel.

    Example Usage:
        ```lua
        hook.Add("OnOpenVendorMenu", "liaExampleOnOpenVendorMenu", function(moduleTable, vendor)
            if moduleTable == MODULE and IsValid(lia.gui.vendor) and IsValid(vendor) then
                lia.gui.vendor:Center()
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorExited()

    Purpose:
        Runs on the client when the vendor session ends and the active vendor panel should be removed.

    Category:
        Vendor

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("VendorExited", "liaExampleVendorExited", function()
            if IsValid(lia.gui.vendor) then
                lia.gui.vendor:Remove()
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
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
