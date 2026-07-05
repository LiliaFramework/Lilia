--[[
    Hooks:
        StorageOpen(storage)

    Purpose:
        Runs when a weight-inventory storage container should open its clientside storage panel.

    Category:
        Inventory

    Parameters:
        storage (Inventory)
            The storage inventory being opened.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("StorageOpen", "liaExampleStorageOpenWeightInv", function(storage)
            print("Opened storage", storage:getID())
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        CanPlayerViewInventory()

    Purpose:
        Determines whether the inventory menu button should be available for the local player.

    Category:
        Inventory

    Parameters:
        None

    Returns:
        boolean|nil
            Return false to hide the inventory menu button. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerViewInventory", "liaExampleCanPlayerViewInventory", function()
            if IsValid(lia.gui.character) then
                return false
            end
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        CanOpenBagPanel(item)

    Purpose:
        Determines whether a bag inventory panel should be opened alongside the main weight inventory.

    Category:
        Inventory

    Parameters:
        item (Item)
            The bag item whose inventory panel is being considered.

    Returns:
        boolean|nil
            Return false to suppress opening the bag panel. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanOpenBagPanel", "liaExampleCanOpenBagPanel", function(item)
            if item.uniqueID == "hiddenbag" then
                return false
            end
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        PostDrawInventory(mainPanel, parentPanel)

    Purpose:
        Runs after the weight inventory panels have been laid out and VGUI finished rendering for the frame.

    Category:
        Inventory

    Parameters:
        mainPanel (Panel)
            The primary inventory panel created for the player's inventory.

        parentPanel (Panel)
            The parent panel that hosted the inventory layout.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PostDrawInventory", "liaExamplePostDrawInventory", function(mainPanel, parentPanel)
            surface.SetDrawColor(255, 255, 255, 10)
        end)
        ```

    Realm:
        Client
]]
function MODULE:CreateInventoryPanel(inventory, parent)
    if inventory.typeID ~= "WeightInv" then return end
    local panel = parent:Add("liaListInventory")
    panel:setInventory(inventory)
    panel:Center()
    return panel
end

function MODULE:StorageOpen(storage)
    if IsValid(storage) and storage:getStorageInfo().invType == INV_TYPE_ID then vgui.Create("liaListStorage"):setStorage(storage) end
end

hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
    local margin = 10
    tabs["inv"] = {
        name = "inv",
        shouldShow = function() return hook.Run("CanPlayerViewInventory") ~= false end,
        func = function(parentPanel)
            local inventory = LocalPlayer():getChar():getInv()
            if not inventory then return end
            local mainPanel = inventory:show(parentPanel)
            local panels = {}
            local totalWidth = 0
            local maxHeight = 0
            table.insert(panels, mainPanel)
            totalWidth = totalWidth + mainPanel:GetWide() + margin
            maxHeight = math.max(maxHeight, mainPanel:GetTall())
            for _, item in pairs(inventory:getItems()) do
                if item.isBag and hook.Run("CanOpenBagPanel", item) ~= false then
                    local bagInv = item:getInv()
                    if bagInv then
                        local bagPanel = bagInv:show(mainPanel)
                        lia.gui["inv" .. bagInv:getID()] = bagPanel
                        table.insert(panels, bagPanel)
                        totalWidth = totalWidth + bagPanel:GetWide() + margin
                        maxHeight = math.max(maxHeight, bagPanel:GetTall())
                    end
                end
            end

            local px, py, pw, ph = mainPanel:GetBounds()
            local xPos = px + pw / 2 - totalWidth / 2
            local yPos = py + ph / 2
            for _, panel in pairs(panels) do
                panel:ShowCloseButton(false)
                panel:SetPos(xPos, yPos - panel:GetTall() / 2)
                xPos = xPos + panel:GetWide() + margin
            end

            hook.Add("PostRenderVGUI", mainPanel, function() hook.Run("PostDrawInventory", mainPanel, parentPanel) end)
        end
    }
end)
