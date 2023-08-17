HOOKS:
CLIENT
hook.Run("ShouldHideBars")
hook.Run("ShouldBarDraw", bar)
hook.Run("CanPlayerViewInventory") 
hook.Run("CanPlayerViewClasses")
hook.Run("ShouldDrawCrosshair")
hook.Run("CanPlayerEquipItem")
hook.Run("CanPlayerTakeItem")
hook.Run("CanPlayerDropItem")
hook.Run("CheckFactionLimitReached", faction, character, client)
hook.Run("GetSalaryAmount", client, faction, class) or (class and class.pay) or (faction and faction.pay) or nil
hook.Run("GetSalaryLimit", client, faction, class) or (class and class.payLimit) or (faction and faction.playLimit) or nil

hook.Run("CanPlayerJoinClass", client, class, info)
ITEM

hook.Run("CanOpenBagPanel", item)
hook.Run("CanPlayerEquipItem", client, item) 



hook.Run("GetMoneyModel", self:getAmount())
hook.Run("OnPickupMoney", activator, self)


hook.Run("OnItemSpawned", self)