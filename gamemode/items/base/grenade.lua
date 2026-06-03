ITEM.name = "grenadeName"
ITEM.desc = "grenadeDesc"
ITEM.category = "itemCatGrenades"
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
ITEM.class = "weapon_frag"
ITEM.width = 1
ITEM.height = 1
ITEM.DropOnDeath = true
ITEM.functions.Use = {
    name = "useGrenade",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        if IsValid(client:GetRagdollEntity()) then
            client:notifyErrorLocalized("noRagdollAction")
            return false
        end

        if client:HasWeapon(item.class) then
            client:notifyErrorLocalized("alreadyHaveGrenade")
            return false
        end

        client:Give(item.class)
        return true
    end,
}
