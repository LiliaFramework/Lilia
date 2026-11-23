ITEM.name = "Grenade Base"
ITEM.desc = "Base item for grenades."
ITEM.category = "Grenades"
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
ITEM.class = "weapon_frag"
ITEM.width = 1
ITEM.height = 1
ITEM.DropOnDeath = true
ITEM.functions.Use = {
    name = "Use Grenade",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        if IsValid(client:GetRagdollEntity()) then
            client:notifyError(string.format("You cannot do that while ragdolled."))
            return false
        end

        if client:HasWeapon(item.class) then
            client:notifyError(string.format("You already have this type of grenade."))
            return false
        end

        client:Give(item.class)
        return true
    end,
}
