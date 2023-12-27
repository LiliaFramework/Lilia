--------------------------------------------------------------------------------------------------------------------------
lia.config.Font = lia.config.Font
-----------------------------------------------------------------------------------------------------------------------------------------------
lia.config.GenericFont = lia.config.GenericFont
-----------------------------------------------------------------------------------------------------------------------------------------------
local DescWidth = CreateClientConVar("lia_hud_descwidth", 0.5, true, false)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local blurGoal = 0
-----------------------------------------------------------------------------------------------------------------------------------------------
local blurValue = 0
--------------------------------------------------------------------------------------------------------------------------
function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    vgui.Create("liaQuick")
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:SetupQuickMenu(menu)
    local current
    LIA_CVAR_LANG = CreateClientConVar("lia_language", "english", true, true)
    for k, v in SortedPairs(lia.lang.stored) do
        local name = lia.lang.names[k]
        local name2 = k:sub(1, 1):upper() .. k:sub(2)
        local enabled = LIA_CVAR_LANG:GetString():match(k)
        if name then
            name = name .. " (" .. name2 .. ")"
        else
            name = name2
        end

        local button = menu:addCheck(
            name,
            function(panel)
                panel.checked = true
                if IsValid(current) then
                    if current == panel then return end
                    current.checked = false
                end

                current = panel
                RunConsoleCommand("lia_language", k)
            end,
            enabled
        )

        if enabled and not IsValid(current) then current = button end
    end

    menu:addSlider("HUD Desc Width Modifier", function(panel, value) DescWidth:SetFloat(value) end, DescWidth:GetFloat(), 0.1, 1, 2)
    menu:addSpacer()
end

--------------------------------------------------------------------------------------------------------------------------
function GM:ScreenResolutionChanged(oldW, oldH)
    RunConsoleCommand("fixchatplz")
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:HUDPaintBackground()
    local localPlayer = LocalPlayer()
    local frameTime = FrameTime()
    local scrW, scrH = ScrW(), ScrH()
    blurGoal = localPlayer:getLocalVar("blur", 0) + (hook.Run("AdjustBlurAmount", blurGoal) or 0)
    if blurValue ~= blurGoal then blurValue = math.Approach(blurValue, blurGoal, frameTime * 20) end
    if blurValue > 0 and not localPlayer:ShouldDrawLocalPlayer() then lia.util.drawBlurAt(0, 0, scrW, scrH, blurValue) end
    self.BaseClass.PaintWorldTips(self.BaseClass)
    lia.menu.drawAll()
end

--------------------------------------------------------------------------------------------------------------------------
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
        if (hook.Run("onCanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and (not v.onCanRun(itemTable)) then continue end
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
--------------------------------------------------------------------------------------------------------------------------
