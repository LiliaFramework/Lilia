function GM:NetworkEntityCreated(entity)
    if entity:IsPlayer() then
        if entity ~= LocalPlayer() then
            hook.Run("PlayerModelChanged", entity, entity:GetModel())
        end
    end
end

function GM:CreateLoadingScreen()
    if IsValid(lia.gui.loading) then
        lia.gui.loading:Remove()
    end

    local loader = vgui.Create("EditablePanel")
    loader:ParentToHUD()
    loader:Dock(FILL)

    loader.Paint = function(this, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    local label = loader:Add("DLabel")
    label:Dock(FILL)
    label:SetText(L"loading")
    label:SetFont("liaNoticeFont")
    label:SetContentAlignment(5)
    label:SetTextColor(color_white)
    label:InvalidateLayout(true)
    label:SizeToContents()

    timer.Simple(5, function()
        if IsValid(lia.gui.loading) then
            local fault = getNetVar("dbError")

            if fault then
                label:SetText(fault and L"dbError" or L"loading")
                local label = loader:Add("DLabel")
                label:DockMargin(0, 64, 0, 0)
                label:Dock(TOP)
                label:SetFont("liaSubTitleFont")
                label:SetText(fault)
                label:SetContentAlignment(5)
                label:SizeToContentsY()
                label:SetTextColor(Color(255, 50, 50))
            end
        end
    end)

    lia.gui.loading = loader
end

function GM:ShouldCreateLoadingScreen()
    return not IsValid(lia.gui.loading)
end

function GM:InitializedConfig()
    hook.Run("LoadLiliaFonts", CONFIG.Font, CONFIG.GenericFont)

        if hook.Run("ShouldCreateLoadingScreen") ~= false then
            hook.Run("CreateLoadingScreen")
        end

        print("LOADED CONFIG!")

end

function GM:CharacterListLoaded()
    local shouldPlayIntro = CONFIG.AlwaysPlayIntro or not lia.localData.intro or nil

    timer.Create("liaWaitUntilPlayerValid", 0.5, 0, function()
        if not IsValid(LocalPlayer()) then return end
        timer.Remove("liaWaitUntilPlayerValid")

        -- Remove the loading indicator.
        if IsValid(lia.gui.loading) then
            lia.gui.loading:Remove()
        end

        RunConsoleCommand("stopsound")
        -- Show the intro if needed, then show the character menu.
        local intro = shouldPlayIntro and hook.Run("CreateIntroduction") or nil

        if IsValid(intro) then
            intro.liaLoadOldRemove = intro.OnRemove

            intro.OnRemove = function(panel)
                panel:liaLoadOldRemove()
                hook.Run("LiliaLoaded")
            end

            lia.gui.intro = intro
        else
            hook.Run("LiliaLoaded")
        end
    end)
end

function GM:InitPostEntity()
    lia.joinTime = RealTime() - 0.9716
    lia.faction.formatModelData()
end

function GM:CalcView(client, origin, angles, fov)
    local view = self.BaseClass:CalcView(client, origin, angles, fov)
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local ragdoll = client:GetRagdollEntity()
    if client:GetViewEntity() ~= client then return view end

    if (not client:ShouldDrawLocalPlayer() and IsValid(entity) and entity:IsRagdoll()) or (not LocalPlayer():Alive() and IsValid(ragdoll)) then
        -- First person if the player has fallen over.
        -- Also first person if the player is dead.
        local ent = LocalPlayer():Alive() and entity or ragdoll
        local index = ent:LookupAttachment("eyes")

        if index then
            local data = ent:GetAttachment(index)

            if data then
                view = view or {}
                view.origin = data.Pos
                view.angles = data.Ang
            end

            return view
        end
    end

    return view
end

local blurGoal = 0
local blurValue = 0
local mathApproach = math.Approach

function GM:HUDPaintBackground()
    local localPlayer = LocalPlayer()
    local frameTime = FrameTime()
    local scrW, scrH = ScrW(), ScrH()
    -- Make screen blurry if blur local var is set.
    blurGoal = localPlayer:getLocalVar("blur", 0) + (hook.Run("AdjustBlurAmount", blurGoal) or 0)

    if blurValue ~= blurGoal then
        blurValue = mathApproach(blurValue, blurGoal, frameTime * 20)
    end

    if blurValue > 0 and not localPlayer:ShouldDrawLocalPlayer() then
        lia.util.drawBlurAt(0, 0, scrW, scrH, blurValue)
    end

    self.BaseClass.PaintWorldTips(self.BaseClass)
    lia.menu.drawAll()
end

function GM:ShouldDrawEntityInfo(entity)
    if entity:IsPlayer() or IsValid(entity:getNetVar("player")) then return entity == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end

    return false
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()

    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()

        if menu and lia.menu.onButtonPressed(menu, callback) then
            return true
        elseif bind:find("use") and pressed then
            local data = {}
            data.start = client:GetShootPos()
            data.endpos = data.start + client:GetAimVector() * 96
            data.filter = client
            local trace = util.TraceLine(data)
            local entity = trace.Entity

            if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then
                hook.Run("ItemShowEntityMenu", entity)
            end
        end
    elseif bind:find("jump") then
        lia.command.send("chargetup")
    end
end

-- Called when use has been pressed on an item.
function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then
            table.remove(lia.menu.list, k)
        end
    end

    local options = {}
    local itemTable = entity:getItemTable()
    if not itemTable then return end -- MARK: This is the where error came from.

    local function callback(index)
        if IsValid(entity) then
            netstream.Start("invAct", index, entity)
        end
    end

    itemTable.player = LocalPlayer()
    itemTable.entity = entity

    if input.IsShiftDown() then
        callback("take")
    end

    for k, v in SortedPairs(itemTable.functions) do
        if k == "combine" then continue end -- yeah, noob protection
        if (hook.Run("onCanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and (not v.onCanRun(itemTable)) then continue end

        options[L(v.name or k)] = function()
            local send = true

            if v.onClick then
                send = v.onClick(itemTable)
            end

            if v.sound then
                surface.PlaySound(v.sound)
            end

            if send ~= false then
                callback(k)
            end
        end
    end

    if table.Count(options) > 0 then
        entity.liaMenuIndex = lia.menu.add(options, entity)
    end

    itemTable.player = nil
    itemTable.entity = nil
end

function GM:SetupQuickMenu(menu)
    menu:addCheck(L"cheapBlur", function(panel, state)
        if state then
            RunConsoleCommand("lia_cheapblur", "1")
        else
            RunConsoleCommand("lia_cheapblur", "0")
        end
    end, LIA_CVAR_CHEAP:GetBool())

    menu:addSpacer()
    local current

    for k, v in SortedPairs(lia.lang.stored) do
        local name = lia.lang.names[k]
        local name2 = k:sub(1, 1):upper() .. k:sub(2)
        local enabled = LIA_CVAR_LANG:GetString():match(k)

        if name then
            name = name .. " (" .. name2 .. ")"
        else
            name = name2
        end

        local button = menu:addCheck(name, function(panel)
            panel.checked = true

            if IsValid(current) then
                if current == panel then return end
                current.checked = false
            end

            current = panel
            RunConsoleCommand("lia_language", k)
        end, enabled)

        if enabled and not IsValid(current) then
            current = button
        end
    end
end

function GM:DrawLiliaModelView(panel, ent)
    if IsValid(ent.weapon) then
        ent.weapon:DrawModel()
    end
end

function GM:ScreenResolutionChanged(oldW, oldH)
    RunConsoleCommand("fixchatplz")
    hook.Run("LoadLiliaFonts", CONFIG.Font, CONFIG.GenericFont)
end

function GM:LiliaLoaded()
    local namecache = {}

    for _, MODULE in pairs(lia.module.list) do
        local authorID = (tonumber(MODULE.author) and tostring(MODULE.author)) or (string.match(MODULE.author, "STEAM_") and util.SteamIDTo64(MODULE.author)) or nil

        if authorID then
            if namecache[authorID] ~= nil then
                MODULE.author = namecache[authorID]
            else
                steamworks.RequestPlayerInfo(authorID, function(newName)
                    namecache[authorID] = newName
                    MODULE.author = newName or MODULE.author
                end)
            end
        end
    end

    lia.module.namecache = namecache
end