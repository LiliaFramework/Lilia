ITEM.name = "Ammo Base" -- The name of the item
ITEM.model = "models/Items/BoxSRounds.mdl" -- The model of the item
ITEM.width = 1 -- The width of the item in the inventory grid
ITEM.height = 1 -- The height of the item in the inventory grid
ITEM.isStackable = true -- Indicates that the item can be stacked
ITEM.maxQuantity = 45 -- The maximum quantity of the item in a stack
ITEM.ammo = "pistol" -- The type of ammo contained in the item
ITEM.desc = "A Box that contains %s of Pistol Ammo" -- The description of the item
ITEM.category = "Ammunition" -- The category of the item

-- Custom function to get the description of the item
function ITEM:getDesc()
    return Format(self.ammoDesc or self.desc, self:getQuantity())
end

-- Custom function to paint over the item's icon
function ITEM:paintOver(item, w, h)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "liaChatFont")
end

-- The available options for loading ammo
local loadAmount = {5, 10, 30, 45, 90, 150, 300}

-- The "use" function of the item
ITEM.functions.use = {
    name = "Load", -- The name of the function
    tip = "useTip", -- The tooltip for the function
    icon = "icon16/add.png", -- The icon used for the function
    isMulti = true, -- Indicates that the function has multiple options
    multiOptions = function(item, client)
        local options = {}

        table.insert(options, {
            name = L("ammoLoadAll"),
            data = 0,
        })

        for _, amount in pairs(loadAmount) do
            if amount <= item:getQuantity() then
                table.insert(options, {
                    name = L("ammoLoadAmount", amount),
                    data = amount,
                })
            end
        end

        table.insert(options, {
            name = L("ammoLoadCustom"),
            data = -1,
        })

        return options
    end,
    -- Function to generate the multi-options for the function
    onClick = function(item, data)
        if data == -1 then return false end
    end,
    -- The function to execute when an option is clicked
    onRun = function(item, data)
        data = data or 0

        if data > 0 then
            local num = tonumber(data)
            item:addQuantity(-num)
            item.player:GiveAmmo(num, item.ammo)
            item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
        elseif data == 0 then
            item.player:GiveAmmo(item:getQuantity(), item.ammo)
            item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)

            return true
        end

        return item:getQuantity() <= 0
    end,
}
-- The function to run when the "use" function is executed