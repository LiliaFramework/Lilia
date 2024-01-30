---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Draw shadows for entities  ]]
EntityPerfomanceCore.DrawEntityShadows = true
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Time between Garbage Cleaning ]]
EntityPerfomanceCore.GarbageCleaningTimer = 60
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Time between Ragdolling Cleaning ]]
EntityPerfomanceCore.RagdollCleaningTimer = 300
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
--[[ Entities that heavily impact performance ]]
EntityPerfomanceCore.Perfomancekillers = {"class C_PhysPropClientside", "class C_ClientRagdoll"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
EntityPerfomanceCore.SoundsToMute = {
    "weapons/airboat/airboat_gun_lastshot1.wav", -- ToolGun Sound
    "weapons/airboat/airboat_gun_lastshot2.wav",
}

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
EntityPerfomanceCore.UnOptimizableModels = {"models/props_office/computer_monitor01.mdl", "models/props_office/computer_monitor02.mdl", "models/props_office/computer_monitor03.mdl", "models/props_office/computer_monitor04.mdl"}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
