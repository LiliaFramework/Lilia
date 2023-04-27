function GM:LoadLiliaFonts(font, genericFont)
    local oldFont, oldGenericFont = font, genericFont
    local scale = math.Round(lia.config.get("fontScale", 1), 2)

    surface.CreateFont("MAIN_Font32", {
        font = "Roboto Condensed",
        extended = false,
        size = 24,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
    })

    surface.CreateFont("MAIN_Font24", {
        font = "Roboto",
        extended = false,
        size = 24,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
    })

    surface.CreateFont("liaSmallChatFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 750
    })

    surface.CreateFont("liaItalicsChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 600,
        italic = true
    })

    surface.CreateFont("liaMediumChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaBigChatFont", {
        font = font,
        size = math.max(ScreenScale(8), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("lia3D2DFont", {
        font = font,
        size = 2048,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaTitleFont", {
        font = font,
        size = ScreenScale(30) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaSubTitleFont", {
        font = font,
        size = ScreenScale(18) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaMenuButtonFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMenuButtonLightFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaDynFontSmall", {
        font = font,
        size = ScreenScale(22) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontMedium", {
        font = font,
        size = ScreenScale(28) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontBig", {
        font = font,
        size = ScreenScale(48) * scale,
        extended = true,
        weight = 1000
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("liaCleanTitleFont", {
        font = font,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaHugeFont", {
        font = font,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaBigFont", {
        font = font,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumLightFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaGenericFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaGenericLightFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("liaChatFontBold", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("liaSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("liaSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaIconsSmallNew", {
        font = "nsicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMediumNew", {
        font = "nsicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBigNew", {
        font = "nsicons",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaNoticeFont", {
        font = genericFont,
        size = 22,
        weight = 500,
        extended = true,
        antianuts = true
    })

    surface.CreateFont("lia3D2DFont", {
        font = font,
        size = 2048,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaTitleFont", {
        font = font,
        size = ScreenScale(30) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaSubTitleFont", {
        font = font,
        size = ScreenScale(18) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaMenuButtonFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMenuButtonLightFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaDynFontSmall", {
        font = font,
        size = ScreenScale(22) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontMedium", {
        font = font,
        size = ScreenScale(28) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontBig", {
        font = font,
        size = ScreenScale(48) * scale,
        extended = true,
        weight = 1000
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("liaCleanTitleFont", {
        font = font,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaHugeFont", {
        font = font,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaBigFont", {
        font = font,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumLightFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaGenericFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaGenericLightFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("liaChatFontBold", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("liaSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("liaSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaIconsSmallNew", {
        font = "nsicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMediumNew", {
        font = "nsicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBigNew", {
        font = "nsicons",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaNoticeFont", {
        font = genericFont,
        size = 22,
        weight = 500,
        extended = true,
        antialias = true
    })

    surface.CreateFont("ix3D2DFont", {
        font = font,
        size = 128,
        extended = true,
        weight = 100
    })

    surface.CreateFont("ix3D2DMediumFont", {
        font = font,
        size = 48,
        extended = true,
        weight = 100
    })

    surface.CreateFont("ix3D2DSmallFont", {
        font = font,
        size = 24,
        extended = true,
        weight = 400
    })

    surface.CreateFont("ixTitleFont", {
        font = font,
        size = ScreenScale(30),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixSubTitleFont", {
        font = font,
        size = ScreenScale(16),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuMiniFont", {
        font = "Roboto",
        size = math.max(ScreenScale(4), 18),
        weight = 300,
    })

    surface.CreateFont("ixMenuButtonFont", {
        font = "Roboto Th",
        size = ScreenScale(14),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuButtonFontSmall", {
        font = "Roboto Th",
        size = ScreenScale(10),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuButtonFontThick", {
        font = "Roboto",
        size = ScreenScale(14),
        extended = true,
        weight = 300
    })

    surface.CreateFont("ixMenuButtonLabelFont", {
        font = "Roboto Th",
        size = 28,
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuButtonHugeFont", {
        font = "Roboto Th",
        size = ScreenScale(24),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("ixMonoSmallFont", {
        font = "Consolas",
        size = 12,
        extended = true,
        weight = 800
    })

    surface.CreateFont("ixMonoMediumFont", {
        font = "Consolas",
        size = 22,
        extended = true,
        weight = 800
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("ixBigFont", {
        font = font,
        size = 36,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("ixMediumFont", {
        font = font,
        size = 25,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("ixNoticeFont", {
        font = font,
        size = math.max(ScreenScale(8), 18),
        weight = 100,
        extended = true,
        antialias = true
    })

    surface.CreateFont("ixMediumLightFont", {
        font = font,
        size = 25,
        extended = true,
        weight = 200
    })

    surface.CreateFont("ixMediumLightBlurFont", {
        font = font,
        size = 25,
        extended = true,
        weight = 200,
        blursize = 4
    })

    surface.CreateFont("ixGenericFont", {
        font = font,
        size = 20,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("ixChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * 1,
        extended = true,
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ixChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * 1,
        extended = true,
        weight = 600,
        antialias = true,
        italic = true
    })

    surface.CreateFont("ixSmallTitleFont", {
        font = "Roboto Th",
        size = math.max(ScreenScale(12), 24),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMinimalTitleFont", {
        font = "Roboto",
        size = math.max(ScreenScale(8), 22),
        extended = true,
        weight = 800
    })

    surface.CreateFont("ixSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 500
    })

    surface.CreateFont("ixItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("ixSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20),
        extended = true,
        weight = 800
    })

    surface.CreateFont("ixItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20),
        extended = true,
        weight = 800
    })

    -- Introduction fancy font.
    font = "Roboto Th"

    surface.CreateFont("ixIntroTitleFont", {
        font = font,
        size = math.min(ScreenScale(128), 128),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIntroTitleBlurFont", {
        font = font,
        size = math.min(ScreenScale(128), 128),
        extended = true,
        weight = 100,
        blursize = 4
    })

    surface.CreateFont("ixIntroSubtitleFont", {
        font = font,
        size = ScreenScale(24),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIntroSmallFont", {
        font = font,
        size = ScreenScale(14),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("ixSmallTitleIcons", {
        font = "fontello",
        size = math.max(ScreenScale(11), 23),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("ixIconsMenuButton", {
        font = "fontello",
        size = ScreenScale(14),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    hook.Run("LoadFonts", oldFont, oldGenericFont)
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
    hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"))

    if not lia.config.loaded then
        if hook.Run("ShouldCreateLoadingScreen") ~= false then
            hook.Run("CreateLoadingScreen")
        end

        lia.config.loaded = true
    end
end

function GM:CharacterListLoaded()
    local shouldPlayIntro = lia.config.get("alwaysPlayIntro", true) or not lia.localData.intro or nil

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
    elseif bind:find("speed") and client:KeyDown(IN_WALK) and pressed then
        if LocalPlayer():Crouching() then
            RunConsoleCommand("-duck")
        else
            RunConsoleCommand("+duck")
        end
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
    -- Performance
    menu:addCheck(L"cheapBlur", function(panel, state)
        if state then
            RunConsoleCommand("lia_cheapblur", "1")
        else
            RunConsoleCommand("lia_cheapblur", "0")
        end
    end, LIA_CVAR_CHEAP:GetBool())

    -- Language settings
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
    hook.Run("LoadLiliaFonts", lia.config.get("font"), lia.config.get("genericFont"))
end

function GM:LiliaLoaded()
    local namecache = {}

    for _, PLUGIN in pairs(lia.plugin.list) do
        local authorID = (tonumber(PLUGIN.author) and tostring(PLUGIN.author)) or (string.match(PLUGIN.author, "STEAM_") and util.SteamIDTo64(PLUGIN.author)) or nil

        if authorID then
            if namecache[authorID] ~= nil then
                PLUGIN.author = namecache[authorID]
            else
                steamworks.RequestPlayerInfo(authorID, function(newName)
                    namecache[authorID] = newName
                    PLUGIN.author = newName or PLUGIN.author
                end)
            end
        end
    end

    lia.plugin.namecache = namecache
end