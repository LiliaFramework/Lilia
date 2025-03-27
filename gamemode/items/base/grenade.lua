ITEM.name = "Grenade Base"
ITEM.desc = "Base item for grenades."
ITEM.category = "Grenades"
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
ITEM.grenadeClass = "weapon_frag"
ITEM.width = 1
ITEM.height = 1
ITEM.DropOnDeath = true
ITEM.functions.Use = {
    name = "Use Grenade",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        if client:hasRagdoll() then
            client:notifyLocalized("noRagdollAction")
            return false
        end

        if client:HasWeapon(item.grenadeClass) then
            client:notifyLocalized("alreadyHaveGrenade")
            return false
        end

        client:Give(item.grenadeClass)
        return true
    end,
}
