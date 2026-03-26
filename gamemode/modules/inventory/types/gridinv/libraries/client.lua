function MODULE:CreateInventoryPanel(inventory, parent)
    local panel = vgui.Create("liaGridInventory", parent)
    panel:setInventory(inventory)
    panel:Center()
    hook.Run("InventoryPanelCreated", panel, inventory, parent)
    return panel
end

function MODULE:InventoryItemRemoved(_, item)
    if not item.isBag then return end
    local bagInv = item:getInv()
    if not bagInv then return end
    local bagID = bagInv:getID()
    local panel = lia.gui["inv" .. bagID]
    if IsValid(panel) then
        panel:Remove()
        lia.gui["inv" .. bagID] = nil
    end
end

function MODULE:InventoryItemAdded(inventory, item)
    if not item.isBag then return end
    local bagInv = item:getInv()
    if not bagInv then return end
    local mainPanel = lia.gui["inv" .. inventory:getID()]
    if not IsValid(mainPanel) then return end
    if hook.Run("CanOpenBagPanel", item) == false then return end
    if IsValid(lia.gui["inv" .. bagInv:getID()]) then return end
    local bagPanel = bagInv:show(mainPanel)
    bagPanel:MoveRightOf(mainPanel, 4)
    lia.gui["inv" .. bagInv:getID()] = bagPanel
end

hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
    local margin = 10
    if hook.Run("CanPlayerViewInventory") == false then return end
    tabs["inv"] = function(parentPanel)
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
end)
