ITEM.name = "grenadeName"
ITEM.desc = "grenadeDesc"
ITEM.category = L("itemCatGrenades")
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
        if client:hasRagdoll() then
            client:notifyLocalized("noRagdollAction")
            return false
        end

        if client:HasWeapon(item.class) then
            client:notifyLocalized("alreadyHaveGrenade")
            return false
        end

        client:Give(item.class)
        return true
    end,
}