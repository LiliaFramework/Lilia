local friendliedNPCs = {}
local hostaliziedNPCs = {}
local passive = {"npc_seagull", "npc_crow", "npc_piegon", "monster_cockroach", "npc_dog", "npc_gman", "npc_antlion_grub", "npc_turret_floor"}
local friendly = {"npc_monk", "npc_alyx", "npc_barney", "npc_citizen", "npc_turret_floor", "npc_dog", "npc_vortigaunt", "npc_kleiner", "npc_eli", "npc_magnusson", "npc_breen", "npc_mossman", "npc_fisherman", "monster_barney", "monster_scientist", "player"}
local hostile = {"npc_turret_ceiling", "npc_combine_s", "npc_combinegunship", "npc_combinedropship", "npc_cscanner", "npc_clawscanner", "npc_turret_floor", "npc_helicopter", "npc_hunter", "npc_manhack", "npc_stalker", "npc_rollermine", "npc_strider", "npc_metropolice", "npc_turret_ground", "npc_cscanner", "npc_clawscanner", "npc_combine_camera", "monster_human_assassin", "monster_human_grunt", "monster_turret", "monster_miniturret", "monster_sentry"}
local monsters = {"npc_antlion", "npc_antlion_worker", "npc_antlionguard", "npc_barnacle", "npc_fastzombie", "npc_fastzombie_torso", "npc_headcrab", "npc_headcrab_fast", "npc_headcrab_black", "npc_headcrab_poison", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "monster_alien_grunt", "monster_alien_slave", "monster_babycrab", "monster_headcrab", "monster_bigmomma", "monster_bullchicken", "monster_barnacle", "monster_alien_controller", "monster_gargantua", "monster_nihilanth", "monster_snark", "monster_zombie", "monster_tentacle", "monster_houndeye"}
local extraItems = {
    {
        ClassName = "weapon_alyxgun",
        PrintName = "#weapon_alyxgun",
        Category = "Half-Life 2",
        Author = "VALVe",
        Spawnable = true
    },
    {
        ClassName = "weapon_oldmanharpoon",
        PrintName = "#weapon_oldmanharpoon",
        Category = "Half-Life 2",
        Author = "VALVe",
        Spawnable = true
    },
    {
        ClassName = "weapon_annabelle",
        PrintName = "#weapon_annabelle",
        Category = "Half-Life 2",
        Author = "VALVe",
        Spawnable = true
    },
    {
        ClassName = "weapon_citizenpackage",
        PrintName = "#weapon_citizenpackage",
        Category = "Half-Life 2",
        Author = "VALVe",
        Spawnable = true
    },
    {
        ClassName = "weapon_citizensuitcase",
        PrintName = "#weapon_citizensuitcase",
        Category = "Half-Life 2",
        Author = "VALVe",
        Spawnable = true
    }
}

local function SetRelationships(ent, tab, status)
    for id, fnpc in pairs(tab) do
        if not IsValid(fnpc) then
            table.remove(tab, id)
        else
            fnpc:AddEntityRelationship(ent, status, 999)
            ent:AddEntityRelationship(fnpc, status, 999)
        end
    end
end

local function Rbt_ProcessOtherNPC(ent)
    if table.HasValue(friendly, ent:GetClass()) and not table.HasValue(hostaliziedNPCs, ent) then
        SetRelationships(ent, friendliedNPCs, D_LI)
        SetRelationships(ent, hostaliziedNPCs, D_HT)
    elseif table.HasValue(hostile, ent:GetClass()) and not table.HasValue(friendliedNPCs, ent) then
        SetRelationships(ent, friendliedNPCs, D_HT)
        SetRelationships(ent, hostaliziedNPCs, D_LI)
    elseif table.HasValue(monsters, ent:GetClass()) and not table.HasValue(friendliedNPCs, ent) and not table.HasValue(hostaliziedNPCs, ent) then
        SetRelationships(ent, friendliedNPCs, D_HT)
        SetRelationships(ent, hostaliziedNPCs, D_HT)
    end
end

local function rb655_property_filter(filtor, ent, ply)
    if isstring(filtor) and filtor ~= ent:GetClass() then return false end
    if istable(filtor) and not table.HasValue(filtor, ent:GetClass()) then return false end
    if isfunction(filtor) and not filtor(ent, ply) then return false end
    return true
end

local function AddEntFunctionProperty(name, label, pos, filtor, func, icon)
    properties.Add(name, {
        MenuLabel = label,
        MenuIcon = icon,
        Order = pos,
        Filter = function(self, ent, ply)
            if not IsValid(ent) or not gamemode.Call("CanProperty", ply, name, ent) then return false end
            if not rb655_property_filter(filtor, ent, ply) then return false end
            return true
        end,
        Action = function(self, ent)
            self:MsgStart()
            net.WriteEntity(ent)
            self:MsgEnd()
        end,
        Receive = function(self, _, ply)
            local ent = net.ReadEntity()
            if not IsValid(ply) or not IsValid(ent) or not self:Filter(ent, ply) then return false end
            func(ent, ply)
        end
    })
end

local allWeapons = CreateConVar("lia_ext_properties_npcallweapons", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, L("changeWeaponPropertyDesc"))
local function GiveWeapon(ply, ent, args)
    if not ent:IsNPC() or not args or not args[1] or not isstring(args[1]) then return end
    local className = args[1]
    local swep
    if allWeapons:GetBool() then
        swep = list.Get("Weapon")[className]
    else
        for _, t in ipairs(list.Get("NPCUsableWeapons")) do
            if t.class == className then
                swep = list.Get("Weapon")[className]
                break
            end
        end
    end

    if swep == nil then
        for _, t in pairs(extraItems) do
            if t.ClassName == className then
                swep = t
                break
            end
        end
    end

    if swep == nil then return end
    if IsValid(ply) then
        local hasPrivilege = ply:hasPrivilege(L("canSpawnSWEPs"))
        if (not swep.Spawnable or swep.AdminOnly) and not hasPrivilege then return end
        if not hook.Run("PlayerGiveSWEP", ply, className, swep) then return end
    end

    ent:Give(className)
    if SERVER then duplicator.StoreEntityModifier(ent, "lia_npc_weapon", args) end
end

duplicator.RegisterEntityModifier("lia_npc_weapon", GiveWeapon)
local function changeWep(it, ent, wep)
    it:MsgStart()
    net.WriteEntity(ent)
    net.WriteString(wep)
    it:MsgEnd()
end

local nowep = {"cycler", "npc_furniture", "monster_generic", "npc_seagull", "npc_crow", "npc_piegon", "npc_rollermine", "npc_turret_floor", "npc_stalker", "npc_turret_ground", "npc_combine_camera", "npc_turret_ceiling", "npc_cscanner", "npc_clawscanner", "npc_manhack", "npc_sniper", "npc_combinegunship", "npc_combinedropship", "npc_helicopter", "npc_antlion_worker", "npc_headcrab_black", "npc_hunter", "npc_vortigaunt", "npc_antlion", "npc_antlionguard", "npc_barnacle", "npc_headcrab", "npc_dog", "npc_gman", "npc_antlion_grub", "npc_strider", "npc_fastzombie", "npc_fastzombie_torso", "npc_headcrab_poison", "npc_headcrab_fast", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "monster_scientist", "monster_zombie", "monster_headcrab", "class C_AI_BaseNPC", "monster_tentacle", "monster_alien_grunt", "monster_alien_slave", "monster_human_assassin", "monster_babycrab", "monster_bullchicken", "monster_cockroach", "monster_alien_controller", "monster_gargantua", "monster_bigmomma", "monster_human_grunt", "monster_houndeye", "monster_nihilanth", "monster_barney", "monster_snark", "monster_turret", "monster_miniturret", "monster_sentry"}
AddEntFunctionProperty("lia_npc_weapon_strip", L("stripWeapon"), 651, function(ent)
    if ent:IsNPC() and IsValid(ent:GetActiveWeapon()) and not table.HasValue(nowep, ent:GetClass()) then return true end
    return false
end, function(ent) ent:GetActiveWeapon():Remove() end, "icon16/gun.png")

properties.Add("lia_npc_weapon", {
    MenuLabel = L("changeWeaponPopup"),
    MenuIcon = "icon16/gun.png",
    Order = 650,
    Filter = function(_, ent, ply)
        if not IsValid(ent) or not gamemode.Call("CanProperty", ply, "lia_npc_weapon", ent) then return false end
        if ent:IsNPC() and not table.HasValue(nowep, ent:GetClass()) then return true end
        return false
    end,
    Action = function(self, ent)
        if not IsValid(ent) then return false end
        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW() / 1.2, ScrH() / 1.1)
        frame:SetTitle(L("changeWeaponOf", language.GetPhrase("#" .. ent:GetClass())))
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(false)
        function frame:Paint(w, h)
            Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        end

        local PropPanel = vgui.Create("ContentContainer", frame)
        PropPanel:SetTriggerSpawnlistChange(false)
        PropPanel:Dock(FILL)
        local Categorised = {}
        Categorised["Half-Life 2"] = table.Copy(extraItems)
        local NPCWeapons = list.Get("NPCUsableWeapons")
        for _, weapon in pairs(list.Get("Weapon")) do
            local NpcUsable = allWeapons:GetBool()
            if not NpcUsable then
                for _, t in ipairs(NPCWeapons) do
                    if t.class == weapon.ClassName then
                        NpcUsable = true
                        break
                    end
                end
            end

            if not NpcUsable or not weapon.Spawnable and not weapon.AdminSpawnable then continue end
            local cat = weapon.Category or L("other")
            if not isstring(cat) then cat = tostring(cat) end
            Categorised[cat] = Categorised[cat] or {}
            table.insert(Categorised[cat], weapon)
        end

        for CategoryName, v in SortedPairs(Categorised) do
            local Header = vgui.Create("ContentHeader", PropPanel)
            Header:SetText(CategoryName)
            PropPanel:Add(Header)
            for _, WeaponTable in SortedPairsByMemberValue(v, "PrintName") do
                if WeaponTable.AdminOnly and not LocalPlayer():hasPrivilege(L("canSpawnSWEPs")) then continue end
                local icon = vgui.Create("ContentIcon", PropPanel)
                icon:SetMaterial("entities/" .. WeaponTable.ClassName .. ".png")
                icon:SetName(WeaponTable.PrintName and language.GetPhrase(WeaponTable.PrintName) or "#" .. WeaponTable.ClassName)
                icon:SetAdminOnly(WeaponTable.AdminOnly or false)
                icon.DoClick = function()
                    changeWep(self, ent, WeaponTable.ClassName)
                    frame:Close()
                end

                PropPanel:Add(icon)
            end
        end

        if allWeapons:GetBool() then
            local WarningThing = vgui.Create("Panel", frame)
            WarningThing:SetHeight(70)
            WarningThing:Dock(BOTTOM)
            WarningThing:DockMargin(0, 5, 0, 0)
            function WarningThing:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
            end

            local WarningText = vgui.Create("DLabel", WarningThing)
            WarningText:Dock(TOP)
            WarningText:SetHeight(35)
            WarningText:SetContentAlignment(5)
            WarningText:SetTextColor(color_white)
            WarningText:SetFont("DermaLarge")
            WarningText:SetText(L("npcWeaponWarning1"))
            local WarningText2 = vgui.Create("DLabel", WarningThing)
            WarningText2:Dock(TOP)
            WarningText2:SetHeight(35)
            WarningText2:SetContentAlignment(5)
            WarningText2:SetTextColor(color_white)
            WarningText2:SetFont("DermaLarge")
            WarningText2:SetText(L("npcWeaponWarning2"))
        end
    end,
    Receive = function(_, _, ply)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        if not ent:IsNPC() or table.HasValue(nowep, ent:GetClass()) then return end
        local wep = net.ReadString()
        GiveWeapon(ply, ent, {wep})
    end
})

AddCSLuaFile()
function AddEntFireProperty(name, label, pos, class, input, icon)
    AddEntFunctionProperty(name, label, pos, class, function(e) e:Fire(unpack(string.Explode(" ", input))) end, icon)
end

if SERVER then
    hook.Add("OnEntityCreated", "lia_properties_friently/hostile", function(ent) if ent:IsNPC() then Rbt_ProcessOtherNPC(ent) end end)
    hook.Add("EntityRemoved", "lia_properties_friently/hostile_remove", function(ent)
        for id, fnpc in pairs(friendliedNPCs) do
            if not IsValid(fnpc) or fnpc == ent then
                table.remove(friendliedNPCs, id)
                break
            end
        end

        for id, fnpc in pairs(hostaliziedNPCs) do
            if not IsValid(fnpc) or fnpc == ent then
                table.remove(hostaliziedNPCs, id)
                break
            end
        end
    end)

    local SyncFuncs = {}
    SyncFuncs.prop_door_rotating = function(ent)
        ent:SetNWBool(L("locked"), ent:GetInternalVariable("m_bLocked"))
        local state = ent:GetInternalVariable("m_eDoorState")
        ent:SetNWBool("Closed", state == 0 or state == 3)
    end

    SyncFuncs.func_door = function(ent) ent:SetNWBool(L("locked"), ent:GetInternalVariable("m_bLocked")) end
    SyncFuncs.func_door_rotating = function(ent) ent:SetNWBool(L("locked"), ent:GetInternalVariable("m_bLocked")) end
    SyncFuncs.prop_vehicle_jeep = function(ent)
        ent:SetNWBool(L("locked"), ent:GetInternalVariable("VehicleLocked"))
        ent:SetNWBool("HasDriver", IsValid(ent:GetDriver()))
        ent:SetNWBool("m_bRadarEnabled", ent:GetInternalVariable("m_bRadarEnabled"))
    end

    SyncFuncs.prop_vehicle_airboat = function(ent)
        ent:SetNWBool(L("locked"), ent:GetInternalVariable("VehicleLocked"))
        ent:SetNWBool("HasDriver", IsValid(ent:GetDriver()))
    end

    SyncFuncs.func_tracktrain = function(ent)
        ent:SetNWInt("m_dir", ent:GetInternalVariable("m_dir"))
        ent:SetNWBool("m_moving", ent:GetInternalVariable("speed") ~= 0)
    end

    local nextSync = 0
    hook.Add("Tick", "lia_propperties_sync", function()
        if nextSync > CurTime() then return end
        nextSync = CurTime() + 1
        for _, ent in ents.Iterator() do
            if SyncFuncs[ent:GetClass()] then SyncFuncs[ent:GetClass()](ent) end
        end
    end)
end

local ExplodeIcon = "icon16/bomb.png"
local EnableIcon = "icon16/tick.png"
local DisableIcon = "icon16/cross.png"
local ToggleIcon = "icon16/arrow_switch.png"
AddEntFireProperty("lia_door_open", L("open"), 655, function(ent, ply)
    if not ent:GetNWBool("Closed") and ent:GetClass() == "prop_door_rotating" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door"}, ent, ply)
end, "Open", "icon16/door_open.png")

AddEntFireProperty("lia_door_close", L("close"), 656, function(ent, ply)
    if ent:GetNWBool("Closed") and ent:GetClass() == "prop_door_rotating" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door"}, ent, ply)
end, "Close", "icon16/door.png")

AddEntFireProperty("lia_door_lock", L("lock"), 657, function(ent, ply)
    if ent:GetNWBool(L("locked")) and ent:GetClass() ~= "prop_vehicle_prisoner_pod" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door", "prop_vehicle_jeep", "prop_vehicle_airboat", "prop_vehicle_prisoner_pod"}, ent, ply)
end, "Lock", "icon16/lock.png")

AddEntFireProperty("lia_door_unlock", L("unlock"), 658, function(ent, ply)
    if not ent:GetNWBool(L("locked")) and ent:GetClass() ~= "prop_vehicle_prisoner_pod" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door", "prop_vehicle_jeep", "prop_vehicle_airboat", "prop_vehicle_prisoner_pod"}, ent, ply)
end, "Unlock", "icon16/lock_open.png")

AddEntFireProperty("lia_func_movelinear_open", L("start"), 655, "func_movelinear", "Open", "icon16/arrow_right.png")
AddEntFireProperty("lia_func_movelinear_close", L("returnText"), 656, "func_movelinear", "Close", "icon16/arrow_left.png")
AddEntFireProperty("lia_func_tracktrain_StartForward", L("startForward"), 655, function(ent, ply)
    if ent:GetNWInt("m_dir") == 1 then return false end
    return rb655_property_filter("func_tracktrain", ent, ply)
end, "StartForward", "icon16/arrow_right.png")

AddEntFireProperty("lia_func_tracktrain_StartBackward", L("startBackward"), 656, function(ent, ply)
    if ent:GetNWInt("m_dir") == -1 then return false end
    return rb655_property_filter("func_tracktrain", ent, ply)
end, "StartBackward", "icon16/arrow_left.png")

AddEntFireProperty("lia_func_tracktrain_Stop", L("stop"), 658, function(ent, ply)
    if not ent:GetNWBool("m_moving") then return false end
    return rb655_property_filter("func_tracktrain", ent, ply)
end, "Stop", "icon16/shape_square.png")

AddEntFireProperty("lia_func_tracktrain_Resume", L("resume"), 659, function(ent, ply)
    if ent:GetNWInt("m_moving") then return false end
    return rb655_property_filter("func_tracktrain", ent, ply)
end, "Resume", "icon16/resultset_next.png")

AddEntFireProperty("lia_breakable_break", L("breakAction"), 655, function(ent, ply)
    if ent:Health() < 1 then return false end
    return rb655_property_filter({"func_breakable", "func_physbox", "prop_physics", "func_pushable"}, ent, ply)
end, "Break", ExplodeIcon)

AddEntFunctionProperty("lia_dissolve", L("disintegrate"), 657, function(ent)
    if ent:GetModel() and ent:GetModel():StartWith("*") then return false end
    if ent:IsPlayer() then return false end
    return true
end, function(ent) ent:Dissolve(0, 100) end, "icon16/wand.png")

AddEntFireProperty("lia_turret_toggle", L("toggle"), 655, {"npc_combine_camera", "npc_turret_ceiling", "npc_turret_floor"}, "Toggle", ToggleIcon)
AddEntFireProperty("lia_self_destruct", L("selfDestruct"), 656, {"npc_turret_floor", "npc_helicopter"}, "SelfDestruct", ExplodeIcon)
AddEntFunctionProperty("lia_turret_ammo_remove", L("depleteAmmo"), 657, function(ent)
    if bit.band(ent:GetSpawnFlags(), 256) == 256 then return false end
    if ent:GetClass() == "npc_turret_floor" or ent:GetClass() == "npc_turret_ceiling" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bor(ent:GetSpawnFlags(), 256))
    ent:Activate()
end, "icon16/delete.png")

AddEntFunctionProperty("lia_turret_ammo_restore", L("restoreAmmo"), 658, function(ent)
    if bit.band(ent:GetSpawnFlags(), 256) == 0 then return false end
    if ent:GetClass() == "npc_turret_floor" or ent:GetClass() == "npc_turret_ceiling" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bxor(ent:GetSpawnFlags(), 256))
    ent:Activate()
end, "icon16/add.png")

AddEntFunctionProperty("lia_turret_make_friendly", L("makeFriendly"), 659, function(ent)
    if bit.band(ent:GetSpawnFlags(), 512) == 512 then return false end
    if ent:GetClass() == "npc_turret_floor" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bor(ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN))
    ent:Activate()
end, "icon16/user_green.png")

AddEntFunctionProperty("lia_turret_make_hostile", L("makeHostile"), 660, function(ent)
    if bit.band(ent:GetSpawnFlags(), 512) == 0 then return false end
    if ent:GetClass() == "npc_turret_floor" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bxor(ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN))
    ent:Activate()
end, "icon16/user_red.png")

AddEntFireProperty("lia_suitcharger_recharge", L("recharge"), 655, "item_suitcharger", "Recharge", "icon16/arrow_refresh.png")
AddEntFireProperty("lia_manhack_jam", L("jam"), 655, "npc_manhack", "InteractivePowerDown", ExplodeIcon)
AddEntFireProperty("lia_scanner_mineadd", L("equipMine"), 655, "npc_clawscanner", "EquipMine", "icon16/add.png")
AddEntFireProperty("lia_scanner_minedeploy", L("deployMine"), 656, "npc_clawscanner", "DeployMine", "icon16/arrow_down.png")
AddEntFireProperty("lia_scanner_disable_spotlight", L("disableSpotlight"), 658, {"npc_clawscanner", "npc_cscanner"}, "DisableSpotlight", DisableIcon)
AddEntFireProperty("lia_rollermine_selfdestruct", L("selfDestruct"), 655, "npc_rollermine", "InteractivePowerDown", ExplodeIcon)
AddEntFireProperty("lia_rollermine_turnoff", L("turnOff"), 656, "npc_rollermine", "TurnOff", DisableIcon)
AddEntFireProperty("lia_rollermine_turnon", L("turnOn"), 657, "npc_rollermine", "TurnOn", EnableIcon)
AddEntFireProperty("lia_helicopter_gun_on", L("enableTurret"), 655, "npc_helicopter", "GunOn", EnableIcon)
AddEntFireProperty("lia_helicopter_gun_off", L("disableTurret"), 656, "npc_helicopter", "GunOff", DisableIcon)
AddEntFireProperty("lia_helicopter_dropbomb", L("dropBomb"), 657, "npc_helicopter", "DropBomb", "icon16/arrow_down.png")
AddEntFireProperty("lia_helicopter_norm_shoot", L("startNormalShooting"), 660, "npc_helicopter", "StartNormalShooting", "icon16/clock.png")
AddEntFireProperty("lia_helicopter_long_shoot", L("startLongCycleShooting"), 661, "npc_helicopter", "StartLongCycleShooting", "icon16/clock_red.png")
AddEntFireProperty("lia_helicopter_deadly_on", L("enableDeadlyShooting"), 662, "npc_helicopter", "EnableDeadlyShooting", EnableIcon)
AddEntFireProperty("lia_helicopter_deadly_off", L("disableDeadlyShooting"), 663, "npc_helicopter", "DisableDeadlyShooting", DisableIcon)
AddEntFireProperty("lia_gunship_OmniscientOn", L("enableOmniscient"), 655, "npc_combinegunship", "OmniscientOn", EnableIcon)
AddEntFireProperty("lia_gunship_OmniscientOff", L("disableOmniscient"), 656, "npc_combinegunship", "OmniscientOff", DisableIcon)
AddEntFireProperty("lia_gunship_BlindfireOn", L("enableBlindfire"), 657, "npc_combinegunship", "BlindfireOn", EnableIcon)
AddEntFireProperty("lia_gunship_BlindfireOff", L("disableBlindfire"), 658, "npc_combinegunship", "BlindfireOff", DisableIcon)
AddEntFireProperty("lia_alyx_HolsterWeapon", L("holsterWeapon"), 655, function(ent)
    if not ent:IsNPC() or ent:GetClass() ~= "npc_alyx" or not IsValid(ent:GetActiveWeapon()) then return false end
    return true
end, "HolsterWeapon", "icon16/gun.png")

AddEntFireProperty("lia_alyx_UnholsterWeapon", L("unholsterWeapon"), 656, "npc_alyx", "UnholsterWeapon", "icon16/gun.png")
AddEntFireProperty("lia_alyx_HolsterAndDestroyWeapon", L("holsterAndDestroyWeapon"), 657, function(ent)
    if not ent:IsNPC() or ent:GetClass() ~= "npc_alyx" or not IsValid(ent:GetActiveWeapon()) then return false end
    return true
end, "HolsterAndDestroyWeapon", "icon16/gun.png")

AddEntFireProperty("lia_antlion_burrow", L("burrow"), 655, {"npc_antlion", "npc_antlion_worker"}, "BurrowAway", "icon16/arrow_down.png")
AddEntFireProperty("lia_barnacle_free", L("freeTarget"), 655, "npc_barnacle", "LetGo", "icon16/heart.png")
AddEntFireProperty("lia_zombine_suicide", L("suicide"), 655, "npc_zombine", "PullGrenade", ExplodeIcon)
AddEntFireProperty("lia_zombine_sprint", L("sprint"), 656, "npc_zombine", "StartSprint", "icon16/flag_blue.png")
AddEntFireProperty("lia_thumper_enable", L("enable"), 655, "prop_thumper", "Enable", EnableIcon)
AddEntFireProperty("lia_thumper_disable", L("disable"), 656, "prop_thumper", "Disable", DisableIcon)
AddEntFireProperty("lia_dog_fetch_on", L("startPlayingFetch"), 655, "npc_dog", "StartCatchThrowBehavior", "icon16/accept.png")
AddEntFireProperty("lia_dog_fetch_off", L("stopPlayingFetch"), 656, "npc_dog", "StopCatchThrowBehavior", "icon16/cancel.png")
AddEntFireProperty("lia_soldier_look_off", L("enableBlindness"), 655, "npc_combine_s", "LookOff", "icon16/user_green.png")
AddEntFireProperty("lia_soldier_look_on", L("disableBlindness"), 656, "npc_combine_s", "LookOn", "icon16/user_gray.png")
AddEntFireProperty("lia_citizen_wep_pick_on", L("permitWeaponUpgradePickup"), 655, "npc_citizen", "EnableWeaponPickup", EnableIcon)
AddEntFireProperty("lia_citizen_wep_pick_off", L("restrictWeaponUpgradePickup"), 656, "npc_citizen", "DisableWeaponPickup", DisableIcon)
AddEntFireProperty("lia_citizen_panic", L("startPanicking"), 658, {"npc_citizen", "npc_alyx", "npc_barney"}, "SetReadinessPanic", "icon16/flag_red.png")
AddEntFireProperty("lia_citizen_panic_off", L("stopPanicking"), 659, {"npc_citizen", "npc_alyx", "npc_barney"}, "SetReadinessHigh", "icon16/flag_green.png")
AddEntFireProperty("lia_camera_angry", L("makeAngry"), 656, "npc_combine_camera", "SetAngry", "icon16/flag_red.png")
AddEntFireProperty("lia_combine_mine_disarm", L("disarm"), 655, "combine_mine", "Disarm", "icon16/wrench.png")
AddEntFireProperty("lia_hunter_enable", L("enableShooting"), 655, "npc_hunter", "EnableShooting", EnableIcon)
AddEntFireProperty("lia_hunter_disable", L("disableShooting"), 656, "npc_hunter", "DisableShooting", DisableIcon)
AddEntFireProperty("lia_vortigaunt_enable", L("enableArmorRecharge"), 655, "npc_vortigaunt", "EnableArmorRecharge", EnableIcon)
AddEntFireProperty("lia_vortigaunt_disable", L("disableArmorRecharge"), 656, "npc_vortigaunt", "DisableArmorRecharge", DisableIcon)
AddEntFireProperty("lia_antlion_enable", L("enableJump"), 655, {"npc_antlion", "npc_antlion_worker"}, "EnableJump", EnableIcon)
AddEntFireProperty("lia_antlion_disable", L("disableJump"), 656, {"npc_antlion", "npc_antlion_worker"}, "DisableJump", DisableIcon)
AddEntFireProperty("lia_antlion_hear", L("hearBugbait"), 657, {"npc_antlion", "npc_antlion_worker"}, "HearBugbait", EnableIcon)
AddEntFireProperty("lia_antlion_ignore", L("ignoreBugbait"), 658, {"npc_antlion", "npc_antlion_worker"}, "IgnoreBugbait", DisableIcon)
AddEntFireProperty("lia_antlion_grub_squash", L("squash"), 655, "npc_antlion_grub", "Squash", "icon16/bug.png")
AddEntFireProperty("lia_antlionguard_bark_on", L("enableAntlionSummon"), 655, "npc_antlionguard", "EnableBark", EnableIcon)
AddEntFireProperty("lia_antlionguard_bark_off", L("disableAntlionSummon"), 656, "npc_antlionguard", "DisableBark", DisableIcon)
AddEntFireProperty("lia_headcrab_burrow", L("burrow"), 655, "npc_headcrab", "BurrowImmediate", "icon16/arrow_down.png")
AddEntFireProperty("lia_strider_stand", L("forceStand"), 655, "npc_strider", "Stand", "icon16/arrow_up.png")
AddEntFireProperty("lia_strider_crouch", L("forceCrouch"), 656, "npc_strider", "Crouch", "icon16/arrow_down.png")
AddEntFireProperty("lia_strider_break", L("destroy"), 657, {"npc_strider", "npc_clawscanner", "npc_cscanner"}, "Break", ExplodeIcon)
AddEntFireProperty("lia_patrol_on", L("startPatrolling"), 660, {"npc_citizen", "npc_combine_s"}, "StartPatrolling", "icon16/flag_green.png")
AddEntFireProperty("lia_patrol_off", L("stopPatrolling"), 661, {"npc_citizen", "npc_combine_s"}, "StopPatrolling", "icon16/flag_red.png")
AddEntFireProperty("lia_strider_aggressive_e", L("makeMoreAggressive"), 658, "npc_strider", "EnableAggressiveBehavior", EnableIcon)
AddEntFireProperty("lia_strider_aggressive_d", L("makeLessAggressive"), 659, "npc_strider", "DisableAggressiveBehavior", DisableIcon)
AddEntFunctionProperty("lia_healthcharger_recharge", L("recharge"), 655, "item_healthcharger", function(ent)
    local n = ents.Create("item_healthcharger")
    n:SetPos(ent:GetPos())
    n:SetAngles(ent:GetAngles())
    n:Spawn()
    n:Activate()
    n:EmitSound("items/suitchargeok1.wav")
    undo.ReplaceEntity(ent, n)
    cleanup.ReplaceEntity(ent, n)
    ent:Remove()
end, "icon16/arrow_refresh.png")

AddEntFunctionProperty("lia_vehicle_exit", L("kickDriver"), 655, function(ent)
    if ent:IsVehicle() and ent:GetNWBool("HasDriver") then return true end
    return false
end, function(ent)
    if not IsValid(ent:GetDriver()) or not ent:GetDriver().ExitVehicle then return end
    ent:GetDriver():ExitVehicle()
end, "icon16/car.png")

AddEntFireProperty("lia_vehicle_radar", L("enableRadar"), 655, function(ent)
    if not ent:IsVehicle() or ent:GetClass() ~= "prop_vehicle_jeep" then return false end
    if ent:LookupAttachment("controlpanel0_ll") == 0 then return false end
    if ent:LookupAttachment("controlpanel0_ur") == 0 then return false end
    if ent:GetNWBool("m_bRadarEnabled", false) then return false end
    return true
end, "EnableRadar", "icon16/application_add.png")

AddEntFireProperty("lia_vehicle_radar_off", L("disableRadar"), 655, function(ent)
    if not ent:IsVehicle() or ent:GetClass() ~= "prop_vehicle_jeep" then return false end
    if not ent:GetNWBool("m_bRadarEnabled", false) then return false end
    return true
end, "DisableRadar", "icon16/application_delete.png")

AddEntFunctionProperty("lia_vehicle_enter", L("enterVehicle"), 656, function(ent)
    if ent:IsVehicle() and not ent:GetNWBool("HasDriver") then return true end
    return false
end, function(ent, ply)
    ply:ExitVehicle()
    ply:EnterVehicle(ent)
end, "icon16/car.png")

AddEntFunctionProperty("lia_vehicle_add_gun", L("mountGun"), 657, function(ent)
    if not ent:IsVehicle() then return false end
    if ent:GetNWBool("EnableGun", false) then return false end
    if ent:GetBodygroup(1) == 1 then return false end
    if ent:LookupSequence("aim_all") > 0 then return true end
    if ent:LookupSequence("weapon_yaw") > 0 and ent:LookupSequence("weapon_pitch") > 0 then return true end
    return false
end, function(ent)
    ent:SetKeyValue("EnableGun", "1")
    ent:Activate()
    ent:SetBodygroup(1, 1)
    ent:SetNWBool("EnableGun", true)
end, "icon16/gun.png")

AddEntFunctionProperty("lia_baloon_break", L("pop"), 655, "gmod_balloon", function(ent, ply)
    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(ply)
    ent:OnTakeDamage(dmginfo)
end, ExplodeIcon)

AddEntFunctionProperty("lia_dynamite_activate", L("explode"), 655, "gmod_dynamite", function(ent, ply) ent:Explode(0, ply) end, ExplodeIcon)
AddEntFunctionProperty("lia_emitter_on", L("startEmitting"), 655, function(ent)
    if ent:GetClass() == "gmod_emitter" and not ent:GetOn() then return true end
    return false
end, function(ent) ent:SetOn(true) end, EnableIcon)

AddEntFunctionProperty("lia_emitter_off", L("stopEmitting"), 656, function(ent)
    if ent:GetClass() == "gmod_emitter" and ent:GetOn() then return true end
    return false
end, function(ent) ent:SetOn(false) end, DisableIcon)

AddEntFunctionProperty("lia_lamp_on", L("enable"), 655, function(ent)
    if ent:GetClass() == "gmod_lamp" and not ent:GetOn() then return true end
    return false
end, function(ent) ent:Switch(true) end, EnableIcon)

AddEntFunctionProperty("lia_lamp_off", L("disable"), 656, function(ent)
    if ent:GetClass() == "gmod_lamp" and ent:GetOn() then return true end
    return false
end, function(ent) ent:Switch(false) end, DisableIcon)

AddEntFunctionProperty("lia_light_on", L("enable"), 655, function(ent)
    if ent:GetClass() == "gmod_light" and not ent:GetOn() then return true end
    return false
end, function(ent) ent:SetOn(true) end, EnableIcon)

AddEntFunctionProperty("lia_light_off", L("disable"), 656, function(ent)
    if ent:GetClass() == "gmod_light" and ent:GetOn() then return true end
    return false
end, function(ent) ent:SetOn(false) end, DisableIcon)

AddEntFireProperty("lia_func_rotating_forward", L("startForward"), 655, "func_rotating", "StartForward", "icon16/arrow_right.png")
AddEntFireProperty("lia_func_rotating_backward", L("startBackward"), 656, "func_rotating", "StartBackward", "icon16/arrow_left.png")
AddEntFireProperty("lia_func_rotating_reverse", L("reverse"), 657, "func_rotating", "Reverse", "icon16/arrow_undo.png")
AddEntFireProperty("lia_func_rotating_stop", L("stop"), 658, "func_rotating", "Stop", "icon16/shape_square.png")
AddEntFireProperty("lia_func_platrot_up", L("goUp"), 655, "func_platrot", "GoUp", "icon16/arrow_up.png")
AddEntFireProperty("lia_func_platrot_down", L("goDown"), 656, "func_platrot", "GoDown", "icon16/arrow_down.png")
AddEntFireProperty("lia_func_platrot_toggle", L("toggle"), 657, "func_platrot", "Toggle", ToggleIcon)
AddEntFireProperty("lia_func_train_start", L("start"), 655, "func_train", L("start"), "icon16/arrow_right.png")
AddEntFireProperty("lia_func_train_stop", L("stop"), 656, "func_train", "Stop", "icon16/arrow_left.png")
AddEntFireProperty("lia_func_train_toggle", L("toggle"), 657, "func_train", "Toggle", ToggleIcon)
AddEntFunctionProperty("lia_item_suit", L("wear"), 655, function(ent, ply)
    if ent:GetClass() ~= "item_suit" then return false end
    if not ply:IsSuitEquipped() then return true end
    return false
end, function(ent, ply)
    ent:Remove()
    ply:EquipSuit()
end, "icon16/user_green.png")

local CheckFuncs = {}
CheckFuncs["item_ammo_pistol"] = function(ply) return ply:GetAmmoCount("pistol") < 9999 end
CheckFuncs["item_ammo_pistol_large"] = function(ply) return ply:GetAmmoCount("pistol") < 9999 end
CheckFuncs["item_ammo_smg1"] = function(ply) return ply:GetAmmoCount("smg1") < 9999 end
CheckFuncs["item_ammo_smg1_large"] = function(ply) return ply:GetAmmoCount("smg1") < 9999 end
CheckFuncs["item_ammo_smg1_grenade"] = function(ply) return ply:GetAmmoCount("smg1_grenade") < 9999 end
CheckFuncs["item_ammo_ar2"] = function(ply) return ply:GetAmmoCount("ar2") < 9999 end
CheckFuncs["item_ammo_ar2_large"] = function(ply) return ply:GetAmmoCount("ar2") < 9999 end
CheckFuncs["item_ammo_ar2_altfire"] = function(ply) return ply:GetAmmoCount("AR2AltFire") < 9999 end
CheckFuncs["item_ammo_357"] = function(ply) return ply:GetAmmoCount("357") < 9999 end
CheckFuncs["item_ammo_357_large"] = function(ply) return ply:GetAmmoCount("357") < 9999 end
CheckFuncs["item_ammo_crossbow"] = function(ply) return ply:GetAmmoCount("xbowbolt") < 9999 end
CheckFuncs["item_rpg_round"] = function(ply) return ply:GetAmmoCount("rpg_round") < 9999 end
CheckFuncs["item_box_buckshot"] = function(ply) return ply:GetAmmoCount("buckshot") < 9999 end
CheckFuncs["item_battery"] = function(ply) return ply:Armor() < 100 end
CheckFuncs["item_healthvial"] = function(ply) return ply:Health() < 100 end
CheckFuncs["item_healthkit"] = function(ply) return ply:Health() < 100 end
CheckFuncs["item_grubnugget"] = function(ply) return ply:Health() < 100 end
AddEntFunctionProperty("lia_pickupitem", L("pickUp"), 655, function(ent, ply)
    if not table.HasValue(table.GetKeys(CheckFuncs), ent:GetClass()) then return false end
    if CheckFuncs[ent:GetClass()](ply) then return true end
    return false
end, function(ent, ply)
    ply:Give(ent:GetClass())
    ent:Remove()
end, "icon16/user_green.png")

local NPCsThisWorksOn = {}
local function RecalcUsableNPCs()
    for _, class in pairs(friendly) do
        NPCsThisWorksOn[class] = true
    end

    for _, class in pairs(hostile) do
        NPCsThisWorksOn[class] = true
    end

    for _, class in pairs(monsters) do
        NPCsThisWorksOn[class] = true
    end
end

RecalcUsableNPCs()
function ExtProp_AddPassive(class)
    table.insert(passive, class)
end

function ExtProp_AddFriendly(class)
    table.insert(friendly, class)
    RecalcUsableNPCs()
end

function ExtProp_AddHostile(class)
    table.insert(hostile, class)
    RecalcUsableNPCs()
end

function ExtProp_AddMonster(class)
    table.insert(monsters, class)
    RecalcUsableNPCs()
end

AddEntFunctionProperty("lia_make_friendly", L("makeFriendly"), 652, function(ent)
    if ent:IsNPC() and not table.HasValue(passive, ent:GetClass()) and NPCsThisWorksOn[ent:GetClass()] then return true end
    return false
end, function(ent)
    table.insert(friendliedNPCs, ent)
    table.RemoveByValue(hostaliziedNPCs, ent)
    ent:Fire("SetSquad", "")
    if ent:GetClass() == "npc_stalker" then ent:SetSaveValue("m_iPlayerAggression", 0) end
    for _, class in pairs(friendly) do
        ent:AddRelationship(class .. " D_LI 999")
    end

    for _, class in pairs(monsters) do
        ent:AddRelationship(class .. " D_HT 999")
    end

    for _, class in pairs(hostile) do
        ent:AddRelationship(class .. " D_HT 999")
    end

    SetRelationships(ent, friendliedNPCs, D_LI)
    SetRelationships(ent, hostaliziedNPCs, D_HT)
    for _, oent in ents.Iterator() do
        if oent:IsNPC() and oent ~= ent then Rbt_ProcessOtherNPC(oent) end
    end

    ent:Activate()
end, "icon16/user_green.png")

AddEntFunctionProperty("lia_make_hostile", L("makeHostile"), 653, function(ent)
    if ent:IsNPC() and not table.HasValue(passive, ent:GetClass()) and NPCsThisWorksOn[ent:GetClass()] then return true end
    return false
end, function(ent)
    table.insert(hostaliziedNPCs, ent)
    table.RemoveByValue(friendliedNPCs, ent)
    ent:Fire("SetSquad", "")
    if ent:GetClass() == "npc_stalker" then ent:SetSaveValue("m_iPlayerAggression", 1) end
    for _, class in pairs(hostile) do
        ent:AddRelationship(class .. " D_LI 999")
    end

    for _, class in pairs(monsters) do
        ent:AddRelationship(class .. " D_HT 999")
    end

    for _, class in pairs(friendly) do
        ent:AddRelationship(class .. " D_HT 999")
    end

    SetRelationships(ent, friendliedNPCs, D_HT)
    SetRelationships(ent, hostaliziedNPCs, D_LI)
    for _, oent in ents.Iterator() do
        if oent:IsNPC() and oent ~= ent then Rbt_ProcessOtherNPC(oent) end
    end
end, "icon16/user_red.png")
