lia.bootstrap("ArcCW", "Loading ArcCW compatibility...")
hook.Remove("PlayerSpawn", "ArcCW_SpawnAttInv")
RunConsoleCommand("arccw_override_hud_off", "1")
RunConsoleCommand("arccw_override_crosshair_off", 1)
RunConsoleCommand("arccw_mult_defaultammo", 0)
RunConsoleCommand("arccw_enable_dropping", 0)
RunConsoleCommand("arccw_attinv_free", 0)
RunConsoleCommand("arccw_attinv_loseondie", 0)
RunConsoleCommand("arccw_malfunction", 2)
RunConsoleCommand("arccw_npc_atts", 0)
hook.Remove("PlayerCanPickupWeapon", "ArcCW_PlayerCanPickupWeapon")
hook.Add("InitializedModules", "Lilia_ArcCW_OnAttLoad", function()
    for id, atttbl in pairs(ArcCW.AttachmentTable) do
        local uniqueID = "arccw_att_" .. id:lower()
        local item = lia.item.register(uniqueID, "base_arccw_att", false, nil, true)
        item.name = atttbl.PrintName or id
        item.desc = atttbl.Description or "An attachment for ArcCW weapons."
        item.model = "models/Items/BoxSRounds.mdl"
        item.category = "attachments"
        item.width = 1
        item.height = 1
        item.att = id
        item.slot = atttbl.Slot
        item.sortOrder = atttbl.SortOrder
    end
end)
