function MODULE:CreateInventoryPanel(inventory, parent)
    local panel = vgui.Create("liaGridInventory", parent)
    panel:setInventory(inventory)
    panel:Center()
    return panel
end

function MODULE:getItemStackKey(item)
    local elements = {}
    for key, value in SortedPairs(item.data) do
        elements[#elements + 1] = key
        elements[#elements + 1] = value
    end
    return item.uniqueID .. pon.encode(elements)
end

function MODULE:getItemStacks(inventory)
    local stacks = {}
    local stack, key
    for _, item in SortedPairs(inventory:getItems()) do
        key = self:getItemStackKey(item)
        stack = stacks[key] or {}
        stack[#stack + 1] = item
        stacks[key] = stack
    end
    return stacks
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

hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
    local margin = 10
    if hook.Run("CanPlayerViewInventory") == false then return end
    tabs[L("inv")] = function(parentPanel)
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