--------------------------------------------------------------------------------------------------------
hook.Add(
    "CreateInventoryPanel",
    "CreateInventoryPanelEvent",
    function(inventory, parent)
        local panel = vgui.Create("liaGridInventory", parent)
        panel:setInventory(inventory)
        panel:Center()

        return panel
    end
)
--------------------------------------------------------------------------------------------------------
hook.Add(
    "getItemStackKey",
    "getItemStackKeyEvent",
    function(item)
        local elements = {}
        for key, value in SortedPairs(item.data) do
            elements[#elements + 1] = key
            elements[#elements + 1] = value
        end

        return item.uniqueID .. pon.encode(elements)
    end
)
--------------------------------------------------------------------------------------------------------
hook.Add(
    "getItemStacks",
    "getItemStacksEvent",
    function(inventory)
        local stacks = {}
        local stack, key
        for _, item in SortedPairs(inventory:getItems()) do
            key = hook.Run("getItemStackKey", item)
            stack = stacks[key] or {}
            stack[#stack + 1] = item
            stacks[key] = stack
        end

        return stacks
    end
)
--------------------------------------------------------------------------------------------------------