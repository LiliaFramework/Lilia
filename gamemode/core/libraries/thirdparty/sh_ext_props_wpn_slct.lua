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

local function GiveWeapon(client, ent, args)
    if not args or not args[1] or not isstring(args[1]) then return end
    local className = args[1]
    local swep = list.Get("Weapon")[className]
    if swep == nil then
        for id, t in pairs(extraItems) do
            if t.ClassName == className then swep = t end
        end
    end

    if swep == nil then return end
    if IsValid(client) then
        if (not swep.Spawnable and not client:IsAdmin()) or (swep.AdminOnly and not client:IsAdmin()) then return end
        if not hook.Run("PlayerGiveSWEP", client, className, swep) then return end
    end

    ent:Give(className)
    if SERVER then duplicator.StoreEntityModifier(ent, "rb655_npc_weapon", args) end
end

duplicator.RegisterEntityModifier("rb655_npc_weapon", GiveWeapon)
local function changeWep(it, ent, wep)
    it:MsgStart()
    net.WriteEntity(ent)
    net.WriteString(wep)
    it:MsgEnd()
end

local nowep = {"cycler", "npc_furniture", "monster_generic", "npc_seagull", "npc_crow", "npc_piegon", "npc_rollermine", "npc_turret_floor", "npc_stalker", "npc_turret_ground", "npc_combine_camera", "npc_turret_ceiling", "npc_cscanner", "npc_clawscanner", "npc_manhack", "npc_sniper", "npc_combinegunship", "npc_combinedropship", "npc_helicopter", "npc_antlion_worker", "npc_headcrab_black", "npc_hunter", "npc_vortigaunt", "npc_antlion", "npc_antlionguard", "npc_barnacle", "npc_headcrab", "npc_dog", "npc_gman", "npc_antlion_grub", "npc_strider", "npc_fastzombie", "npc_fastzombie_torso", "npc_headcrab_poison", "npc_headcrab_fast", "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "monster_scientist", "monster_zombie", "monster_headcrab", "class C_AI_BaseNPC", "monster_tentacle", "monster_alien_grunt", "monster_alien_slave", "monster_human_assassin", "monster_babycrab", "monster_bullchicken", "monster_cockroach", "monster_alien_controller", "monster_gargantua", "monster_bigmomma", "monster_human_grunt", "monster_houndeye", "monster_nihilanth", "monster_barney", "monster_snark", "monster_turret", "monster_miniturret", "monster_sentry"}
AddEntFunctionProperty("rb655_npc_weapon_strip", "Strip Weapon", 651, function(ent)
    if ent:IsNPC() and IsValid(ent:GetActiveWeapon()) and not table.HasValue(nowep, ent:GetClass()) then return true end
    return false
end, function(ent) ent:GetActiveWeapon():Remove() end, "icon16/gun.png")

properties.Add("rb655_npc_weapon", {
    MenuLabel = "Change Weapon (Popup)",
    MenuIcon = "icon16/gun.png",
    Order = 650,
    Filter = function(self, ent, client)
        if not IsValid(ent) or not gamemode.Call("CanProperty", client, "rb655_npc_weapon", ent) then return false end
        if ent:IsNPC() and not table.HasValue(nowep, ent:GetClass()) then return true end
        return false
    end,
    Action = function(self, ent)
        if not IsValid(ent) then return false end
        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW() / 1.2, ScrH() / 1.1)
        frame:SetTitle("Change weapon of " .. language.GetPhrase("#" .. ent:GetClass()))
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
        for k, weapon in pairs(list.Get("Weapon")) do
            if not weapon.Spawnable and not weapon.AdminSpawnable then continue end
            local cat = weapon.Category or "Other"
            if not isstring(cat) then cat = tostring(cat) end
            Categorised[cat] = Categorised[cat] or {}
            table.insert(Categorised[cat], weapon)
        end

        for CategoryName, v in SortedPairs(Categorised) do
            local Header = vgui.Create("ContentHeader", PropPanel)
            Header:SetText(CategoryName)
            PropPanel:Add(Header)
            for k, WeaponTable in SortedPairsByMemberValue(v, "PrintName") do
                if WeaponTable.AdminOnly and not LocalPlayer():IsAdmin() then continue end
                local icon = vgui.Create("ContentIcon", PropPanel)
                icon:SetMaterial("entities/" .. WeaponTable.ClassName .. ".png")
                icon:SetName(WeaponTable.PrintName or ("#" .. WeaponTable.ClassName))
                icon:SetAdminOnly(WeaponTable.AdminOnly or false)
                icon.DoClick = function()
                    changeWep(self, ent, WeaponTable.ClassName)
                    frame:Close()
                end

                PropPanel:Add(icon)
            end
        end

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
        WarningText:SetText("WARNING! Not all NPCs can use weapons and not all weapons are usable by NPCs.")
        local WarningText2 = vgui.Create("DLabel", WarningThing)
        WarningText2:Dock(TOP)
        WarningText2:SetHeight(35)
        WarningText2:SetContentAlignment(5)
        WarningText2:SetTextColor(color_white)
        WarningText2:SetFont("DermaLarge")
        WarningText2:SetText("This is entirely dependent on the Addon the weapon and the NPC are from. This mod cannot change that.")
    end,
    Receive = function(self, length, client)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        if not ent:IsNPC() or table.HasValue(nowep, ent:GetClass()) then return end
        local wep = net.ReadString()
        GiveWeapon(client, ent, {wep})
    end
})
