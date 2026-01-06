--[[
    Folder: Compatibility
    File:  arccw.md
]]
--[[
    ArcCW Compatibility

    Provides configuration and compatibility settings for the ArcCW (Advanced Realistics Combat Weapons) addon within the Lilia framework.
]]
--[[
    Improvements Done:
        The ArcCW compatibility module configures ArcCW weapon system settings to ensure proper integration with Lilia's gameplay mechanics and UI systems.
        The module disables conflicting HUD elements, crosshair overrides, and ammo dropping features that could interfere with Lilia's custom interface and inventory systems.
        It includes settings for malfunction mechanics, attachment inventory behavior, and NPC attachment handling to maintain balance and consistency.
        The module ensures ArcCW weapons work seamlessly within the framework's combat and progression systems.
]]
RunConsoleCommand("arccw_override_hud_off", "1")
RunConsoleCommand("arccw_override_crosshair_off", 1)
RunConsoleCommand("arccw_mult_defaultammo", 0)
RunConsoleCommand("arccw_enable_dropping", 0)
RunConsoleCommand("arccw_attinv_free", 0)
RunConsoleCommand("arccw_attinv_loseondie", 0)
RunConsoleCommand("arccw_malfunction", 2)
RunConsoleCommand("arccw_npc_atts", 0)
