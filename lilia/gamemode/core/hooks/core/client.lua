local GM = GM or GAMEMODE

function GM:CanDisplayCharacterInfo(client, id)
    LiliaDeprecated("CanDisplayCharacterInfo is deprecated. Use CanDisplayCharInfo for optimization purposes.")
    hook.Run("CanDisplayCharInfo", client, id)
end

function GM:KickedFromCharacter(id, isCurrentChar)
    LiliaDeprecated("KickedFromCharacter is deprecated. Use KickedFromChar for optimization purposes.")
    hook.Run("KickedFromChar", id, isCurrentChar)
end

function GM:CharacterListLoaded(newCharList)
    LiliaDeprecated("CharacterListLoaded is deprecated. Use CharListLoaded for optimization purposes.")
    hook.Run("CharListLoaded", newCharList)
end

function GM:CharacterListUpdated(oldCharList, newCharList)
    LiliaDeprecated("CharacterListUpdated is deprecated. Use CharListUpdated for optimization purposes.")
    hook.Run("CharListUpdated", oldCharList, newCharList)
end


function GM:DrawLiliaModelView(_, entity)
    if IsValid(entity.weapon) then entity.weapon:DrawModel() end
end

function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:InitializedConfig()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("jump") and client:hasRagdoll() then
        lia.command.send("chargetup")
    elseif (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then return true end
        if bind:find("use") then
            local entity = client:GetTracedEntity()
            if IsValid(entity) and entity:isItem() or entity.hasMenu then hook.Run("ItemShowEntityMenu", entity) end
        end
    end
end

function GM:CalcView(client, origin, angles, fov)
    local view = self.BaseClass:CalcView(client, origin, angles, fov)
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local ragdoll = client:GetRagdollEntity()
    if not client:hasValidVehicle() and client:GetViewEntity() == client and (not client:ShouldDrawLocalPlayer() and IsValid(entity) and entity:IsRagdoll()) or (not LocalPlayer():Alive() and IsValid(ragdoll)) then
        local ent = LocalPlayer():Alive() and entity or ragdoll
        local index = ent:LookupAttachment("eyes")
        if index then
            local data = ent:GetAttachment(index)
            if data then
                view = view or {}
                view.origin = data.Pos
                view.angles = data.Ang
                view.znear = 1
            end
            return view
        end
    end
    return view
end

function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then table.remove(lia.menu.list, k) end
    end

    local options = {}
    local itemTable = entity:getItemTable()
    if not itemTable then return end
    local function callback(index)
        if IsValid(entity) then netstream.Start("invAct", index, entity) end
    end

    itemTable.player = LocalPlayer()
    itemTable.entity = entity
    if input.IsShiftDown() then callback("take") end
    for k, v in SortedPairs(itemTable.functions) do
        if k == "combine" then continue end
        if (hook.Run("CanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and (not v.onCanRun(itemTable)) then continue end
        options[L(v.name or k)] = function()
            local send = true
            if v.onClick then send = v.onClick(itemTable) end
            if v.sound then surface.PlaySound(v.sound) end
            if send ~= false then callback(k) end
        end
    end

    if table.Count(options) > 0 then entity.liaMenuIndex = lia.menu.add(options, entity) end
    itemTable.player = nil
    itemTable.entity = nil
end

function GM:LoadLiliaFonts(font, genericFont)
    local oldFont, oldGenericFont = font, genericFont
    local scale = math.Round(1, 2)
    surface.CreateFont("DarkSkinSmall", {
        font = "Roboto",
        size = 14,
        weight = 400
    })

    surface.CreateFont("DarkSkinRegular", {
        font = "Roboto",
        size = 18,
        weight = 400
    })

    surface.CreateFont("DarkSkinMedium", {
        font = "Roboto",
        size = 24,
        weight = 400
    })

    surface.CreateFont("DarkSkinLarge", {
        font = "Roboto",
        size = 32,
        weight = 400
    })

    surface.CreateFont("DarkSkinHuge", {
        font = "Roboto",
        size = 56,
        weight = 400
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
        size = ScreenScale(14),
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

    surface.CreateFont("liaCleanTitleFont", {
        font = genericFont,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaHugeFont", {
        font = genericFont,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaBigFont", {
        font = genericFont,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumFont", {
        font = genericFont,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumLightFont", {
        font = genericFont,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaGenericFont", {
        font = genericFont,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaGenericLightFont", {
        font = genericFont,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaChatFont", {
        font = genericFont,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaChatFontItalics", {
        font = genericFont,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("liaChatFontBold", {
        font = genericFont,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("liaSmallFont", {
        font = genericFont,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaItemDescFont", {
        font = genericFont,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("liaSmallBoldFont", {
        font = genericFont,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaItemBoldFont", {
        font = genericFont,
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
        font = "liaicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMediumNew", {
        font = "liaicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBigNew", {
        font = "liaicons",
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

    surface.CreateFont("roboto", {
        font = "Roboto Bold",
        extended = false,
        size = 25,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("roboton", {
        font = "Roboto",
        extended = false,
        size = 19,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("robotoBig", {
        font = "Roboto Bold",
        extended = false,
        size = 36,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("robotoBig2", {
        font = "Roboto Bold",
        extended = false,
        size = 150,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("liaCharTitleFont", {
        font = font,
        weight = 200,
        size = 70 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharDescFont", {
        font = font,
        weight = 200,
        size = 24 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharSubTitleFont", {
        font = font,
        weight = 200,
        size = 12 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharButtonFont", {
        font = font,
        weight = 200,
        size = 24 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharSmallButtonFont", {
        font = font,
        weight = 200,
        size = 22 * (ScrH() / 900) + 10,
        additive = true
    })

    hook.Run("LoadFonts", oldFont, oldGenericFont)
end

function GM:HUDPaintBackground()
    lia.bar.drawAll()
    lia.menu.drawAll()
    self.BaseClass.PaintWorldTips(self.BaseClass)
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    lia.bar.drawAction()
    vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    lia.bar.drawAction()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
end

function GM:CharListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
        local client = LocalPlayer()
        if not IsValid(client) then return end
        timer.Remove("liaWaitUntilPlayerValid")
        hook.Run("LiliaLoaded")
    end)
end

function GM:SetupQuickMenu(menu)
    local current
    for k, _ in SortedPairs(lia.lang.stored) do
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

        if enabled and not IsValid(current) then current = button end
    end

    menu:addSpacer()
end

function GM:HUDDrawTargetID()
    return false
end

function GM:HUDDrawPickupHistory()
    return false
end

function GM:HUDAmmoPickedUp()
    return false
end

function GM:DrawDeathNotice()
    return false
end