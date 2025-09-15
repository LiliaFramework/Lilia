ITEM.name = "ammoName"
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "pistol"
ITEM.category = "itemCatAmmunition"
ITEM.functions.use = {
    name = "load",
    tip = "useTip",
    icon = "icon16/add.png",
    multiOptions = {
        [L("ammoLoadAll")] = {
            function(item)
                item.player:GiveAmmo(item:getQuantity(), item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return true
            end,
            function() return true end
        },
        [L("ammoLoadAmount", 5)] = {
            function(item)
                item:addQuantity(-5)
                item.player:GiveAmmo(5, item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return item:getQuantity() <= 0
            end,
            function(item) return item:getQuantity() >= 5 end
        },
        [L("ammoLoadAmount", 10)] = {
            function(item)
                item:addQuantity(-10)
                item.player:GiveAmmo(10, item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return item:getQuantity() <= 0
            end,
            function(item) return item:getQuantity() >= 10 end
        },
        [L("ammoLoadAmount", 30)] = {
            function(item)
                item:addQuantity(-30)
                item.player:GiveAmmo(30, item.ammo)
                item.player:EmitSound(item.useSound or "items/ammo_pickup.wav", 110)
                return item:getQuantity() <= 0
            end,
            function(item) return item:getQuantity() >= 30 end
        }
    }
}
function ITEM:getDesc()
    return L("ammoDesc", self:getQuantity())
end
function ITEM:paintOver(item)
    local quantity = item:getQuantity()
    lia.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "liaChatFont")
end
