ITEM.name = "ammoName"
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "pistol"
ITEM.category = L("itemCatAmmunition")
ITEM.functions.use = {
    name = "load",
    tip = "useTip",
    icon = "icon16/add.png",
    isMulti = true,
    multiOptions = function(item)
        local options = {}
        table.insert(options, {
            name = "ammoLoadAll",
            data = 0,
        })

        for _, amount in pairs({5, 10, 30, 45, 90, 150, 300}) do
            if amount <= item:getQuantity() then
                table.insert(options, {
                    name = L("ammoLoadAmount", amount),
                    data = amount,
                })
            end
        end

        table.insert(options, {
            name = "ammoLoadCustom",
            data = -1,
        })
        return options
    end,
    onClick = function(_, data) if data == -1 then return false end end,
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

function ITEM:getDesc()
    return L("ammoDesc", self:getQuantity())
end

function ITEM:paintOver(item)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "liaChatFont")
end