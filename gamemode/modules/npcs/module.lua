MODULE.name = "NPCs"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Provides dialog NPCs, conversations, generated dialog trees, configuration, persistence, networking, and UI."
MODULE.NetworkStrings = {"liaDialogSync", "liaNpcCustomize", "liaNpcDialogServerCallback", "liaNpcDialogRequestResponse", "liaNpcDialogDeliverResponse", "liaNpcDialogNodeSelect", "liaNpcDialogNodeResult", "liaOpenNpcDialog", "liaRequestNPCSelection",}
properties.Add("liaConfigureNPC", {
    MenuLabel = "Configure NPC",
    Order = 100,
    MenuIcon = "icon16/wrench.png",
    Filter = function(_, ent, ply)
        if not IsValid(ent) or not lia.dialog.isDialogNPCEntity(ent) then return false end
        if not lia.admin.canUseDebugProperties(ply) then return false end
        if not IsValid(ply) or not ply.hasPrivilege then return false end
        return ply:hasPrivilege("canManageNPCs") or ply:hasPrivilege("canManageProperties")
    end,
    Action = function(_, ent) lia.dialog.openConfigurationPicker(ent) end
})
