--[[
    Hooks:
        F1MenuOpened(Panel self)

    Purpose:
        Runs after the F1 menu panel is created and registered as the active menu interface.

    Category:
        UI

    Parameters:
        self (Panel)
            The newly created F1 menu panel.

    Example Usage:
        ```lua
        hook.Add("F1MenuOpened", "liaExampleF1MenuOpened", function(self)
            self:SetAlpha(255)
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        F1MenuClosed()

    Purpose:
        Runs when the active F1 menu panel is being removed and its UI state is shutting down.

    Category:
        UI

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("F1MenuClosed", "liaExampleF1MenuClosed", function()
            print("F1 menu closed")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        LoadCharInformation()

    Purpose:
        Runs while the F1 character information panel is being initialized so modules can register sections and fields before the UI is generated.

    Category:
        UI

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("LoadCharInformation", "liaExampleLoadCharInformation", function()
            hook.Run("AddSection", "Example", Color(255, 255, 255), 10, 1)
            hook.Run("AddTextField", "Example", "exampleField", "Example Field", function()
                return "Example Value"
            end)
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        AddSection(string sectionName, Color|nil color, number|nil priority, number|nil location)

    Purpose:
        Registers or updates a character information section in the F1 menu before fields are inserted into it.

    Category:
        UI

    Parameters:
        sectionName (string)
            The section identifier or localized display name used as the section key.

        color (Color|nil)
            The color stored with the section data.

        priority (number|nil)
            The sort priority used when the F1 menu orders sections.

        location (number|nil)
            The stored location value for the section entry.

    Example Usage:
        ```lua
        hook.Add("AddSection", "liaExampleAddSection", function(sectionName, color, priority, location)
            if sectionName == "Example" then
                print(sectionName, priority, location)
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        AddTextField(string sectionName, string fieldName, string labelText, function valueFunc, string|IMaterial|nil icon)

    Purpose:
        Adds a text field definition to an existing F1 character information section when that field name has not already been registered.

    Category:
        UI

    Parameters:
        sectionName (string)
            The section identifier or localized display name that should receive the field.

        fieldName (string)
            The unique field key stored on the section definition.

        labelText (string)
            The label shown beside the text entry.

        valueFunc (function)
            A callback that returns the current string value for the field.

        icon (string|IMaterial|nil)
            Optional material path or material displayed beside the field. No icon is drawn when omitted.

    Example Usage:
        ```lua
        hook.Add("AddTextField", "liaExampleAddTextField", function(sectionName, fieldName, labelText, valueFunc, icon)
            if sectionName == L("generalInfo") and fieldName == "name" then
                print(labelText, valueFunc())
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        AddBarField(string sectionName, string fieldName, string labelText, function|number|nil minFunc, function|number|nil maxFunc, function|number|nil valueFunc, string|IMaterial|nil icon)

    Purpose:
        Adds a progress-bar field definition to an existing F1 character information section when that field name has not already been registered.

    Category:
        UI

    Parameters:
        sectionName (string)
            The section identifier or localized display name that should receive the bar field.

        fieldName (string)
            The unique field key stored on the section definition.

        labelText (string)
            The label shown beside the progress bar.

        minFunc (function|number|nil)
            A callback or numeric value that supplies the bar minimum.

        maxFunc (function|number|nil)
            A callback or numeric value that supplies the bar maximum.

        valueFunc (function|number|nil)
            A callback or numeric value that supplies the current bar value.

        icon (string|IMaterial|nil)
            Optional material path or material displayed beside the bar. No icon is drawn when omitted.

    Example Usage:
        ```lua
        hook.Add("AddBarField", "liaExampleAddBarField", function(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc, icon)
            if sectionName == L("attributesModuleName") and fieldName == "stm" then
                print(labelText, minFunc(), maxFunc(), valueFunc())
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        CreateInformationButtons(table pages)

    Purpose:
        Allows modules to register information-tab pages for the F1 menu before they are filtered, sorted, and rendered.

    Category:
        UI

    Parameters:
        pages (table)
            The mutable array of page definitions consumed by the information tab builder.

    Example Usage:
        ```lua
        hook.Add("CreateInformationButtons", "liaExampleCreateInformationButtons", function(pages)
            pages[#pages + 1] = {
                name = "exampleInfo",
                drawFunc = function(parent)
                    parent:Clear()
                end
            }
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        PopulateConfigurationButtons(table pages)

    Purpose:
        Allows modules to register settings pages for the F1 configuration tab before the menu filters, sorts, and renders them.

    Category:
        UI

    Parameters:
        pages (table)
            The mutable array of configuration page definitions that the settings tab consumes.

    Example Usage:
        ```lua
        hook.Add("PopulateConfigurationButtons", "liaExamplePopulateConfigurationButtons", function(pages)
            pages[#pages + 1] = {
                name = "Example Settings",
                drawFunc = function(parent)
                    parent:Clear()
                end
            }
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        CanDisplayCharInfo(string name)

    Purpose:
        Allows the F1 character information panel to veto specific character information fields before they are shown.

    Category:
        UI

    Parameters:
        name (string)
            The field identifier being considered for display.

    Example Usage:
        ```lua
        hook.Add("CanDisplayCharInfo", "liaExampleCanDisplayCharInfo", function(name)
            if name == "class" then return false end
        end)
        ```

    Returns:
        boolean|nil
            Return false to hide the named field. Return nil or true to leave the field available.

    Realm:
        Client
]]
local function localizeMenuLabel(value, ...)
    if not isstring(value) then return value end
    local resolved = lia.lang.resolveToken(value, ...)
    if resolved ~= value then return resolved end
    return L(value, ...)
end

local function normalizeCharInfoSectionName(value)
    if not isstring(value) then return "" end
    return value:lower():gsub("[^%w]", "")
end

local function resolveCharInfoSectionName(sectionName)
    if not IsValid(lia.gui.info) then return sectionName end
    local localizedSectionName = isstring(sectionName) and L(sectionName) or sectionName
    if lia.gui.info.CharacterInformation[localizedSectionName] then return localizedSectionName end
    local candidates = {}
    if isstring(localizedSectionName) then candidates[#candidates + 1] = normalizeCharInfoSectionName(localizedSectionName) end
    if isstring(sectionName) and sectionName ~= localizedSectionName then candidates[#candidates + 1] = normalizeCharInfoSectionName(sectionName) end
    for existingName in pairs(lia.gui.info.CharacterInformation) do
        if isstring(existingName) then
            local normalizedExisting = normalizeCharInfoSectionName(existingName)
            for _, candidate in ipairs(candidates) do
                if candidate ~= "" and candidate == normalizedExisting then return existingName end
            end
        end
    end

    for existingName in pairs(lia.gui.info.CharacterInformation) do
        if isstring(existingName) then
            local normalizedExisting = normalizeCharInfoSectionName(existingName)
            for _, candidate in ipairs(candidates) do
                if candidate ~= "" and normalizedExisting ~= "" and (candidate:find(normalizedExisting, 1, true) or normalizedExisting:find(candidate, 1, true)) then return existingName end
            end
        end
    end
    return localizedSectionName
end

local function getThemeColors()
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    local text = theme.text or Color(225, 238, 238)
    return accent, text
end

local function drawPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

local function drawIcon(material, x, y, size, color)
    if not material or material:IsError() then return end
    surface.SetMaterial(material)
    surface.SetDrawColor(color or color_white)
    surface.DrawTexturedRect(x, y, size, size)
end

local function resolveIconMaterial(icon, fallback)
    if not icon then return fallback end
    if type(icon) == "IMaterial" then return icon end
    if isstring(icon) and icon ~= "" then return Material(icon, "smooth") end
    return fallback
end

local function getFieldValue(panel, name)
    for _, data in pairs(panel.CharacterInformation or {}) do
        local fields = isfunction(data.fields) and data.fields() or data.fields
        for _, field in ipairs(fields or {}) do
            if field.name == name then
                local value = isfunction(field.value) and field.value() or field.value
                return value ~= nil and tostring(value) or ""
            end
        end
    end
    return ""
end

local sidebarIcons = {
    ["@admin"] = Material("icon16/shield.png", "smooth"),
    ["@characters"] = Material("icon16/user.png", "smooth"),
    ["@classes"] = Material("icon16/group.png", "smooth"),
    ["@information"] = Material("icon16/information.png", "smooth"),
    ["@inventory"] = Material("icon16/box.png", "smooth"),
    ["@logisticslogs"] = Material("icon16/page_white_text.png", "smooth"),
    ["@logisticsstorage"] = Material("icon16/database.png", "smooth"),
    ["@settings"] = Material("icon16/cog.png", "smooth"),
    ["@themes"] = Material("icon16/color_wheel.png", "smooth"),
    ["@you"] = Material("icon16/user.png", "smooth")
}

local function drawcirclepoly(w, h)
    local poly = {}
    local x, y = w / 2, h / 2
    local radius = math.min(w, h) / 2
    for angle = 1, 360 do
        local rad = math.rad(angle)
        poly[#poly + 1] = {
            x = x + math.cos(rad) * radius,
            y = y + math.sin(rad) * radius
        }
    end
    return poly
end

local CIRCULAR_AVATAR = {}
function CIRCULAR_AVATAR:Init()
    self.base = vgui.Create("AvatarImage", self)
    self.base:Dock(FILL)
    self.base:SetPaintedManually(true)
end

function CIRCULAR_AVATAR:GetBase()
    return self.base
end

function CIRCULAR_AVATAR:PushMask(mask)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
    mask()
    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)
end

function CIRCULAR_AVATAR:PopMask()
    render.SetStencilEnable(false)
    render.ClearStencil()
end

function CIRCULAR_AVATAR:OnSizeChanged(w, h)
    self.poly = drawcirclepoly(w, h)
end

function CIRCULAR_AVATAR:Paint(w, h)
    self.poly = self.poly or drawcirclepoly(w, h)
    self:PushMask(function()
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255)
        surface.DrawPoly(self.poly)
    end)

    self.base:PaintManual()
    self:PopMask()
end

function CIRCULAR_AVATAR:SetPlayer(pl, size)
    self.base:SetPlayer(pl, size)
end

vgui.Register("CircularAvatar", CIRCULAR_AVATAR, "Panel")
local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    self:Dock(FILL)
    self.Paint = function() end
    self.CharacterInformation = {}
    self.cards = {}
    hook.Run("LoadCharInformation")
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:SetTall(184)
    self.header:DockMargin(0, 0, 0, 16)
    self.header.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    self.avatarWrap = self.header:Add("DPanel")
    self.avatarWrap:SetSize(136, 136)
    self.avatarWrap.Paint = function() end
    self.avatar = self.avatarWrap:Add("CircularAvatar")
    self.avatar:SetSize(136, 136)
    self.avatar:SetPos(0, 0)
    self.avatar:SetPlayer(LocalPlayer(), 184)
    self.identity = self.header:Add("DPanel")
    self.identity:SetSize(720, 120)
    self.identity.Paint = function() end
    self.characterName = self.identity:Add("DLabel")
    self.characterName:SetFont("LiliaFont.30")
    self.characterName:SetTextColor(Color(242, 247, 247))
    self.characterName:SetPos(0, 4)
    self.characterName:SetSize(700, 40)
    self.characterSubtitle = self.identity:Add("DLabel")
    self.characterSubtitle:SetFont("LiliaFont.20")
    self.characterSubtitle:SetPos(0, 0)
    self.characterSubtitle:SetSize(0, 0)
    self.characterSubtitle:SetText("")
    self.characterSubtitle:SetVisible(false)
    self.chips = self.identity:Add("DPanel")
    self.chips:SetPos(0, 62)
    self.chips:SetSize(700, 52)
    self.chips.Paint = function() end
    self.header.PerformLayout = function(_, w, h)
        local avatarX = 28
        local avatarY = math.floor((h - self.avatarWrap:GetTall()) * 0.5)
        local identityX = avatarX + self.avatarWrap:GetWide() + 26
        local identityY = math.floor((h - 120) * 0.5)
        self.avatarWrap:SetPos(avatarX, avatarY)
        self.identity:SetPos(identityX, identityY)
        self.identity:SetSize(math.max(w - identityX - 28, 100), 120)
        self.characterName:SetWide(self.identity:GetWide())
        self.chips:SetWide(self.identity:GetWide())
    end

    self.scroll = self:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll.Paint = function() end
    local canvas = self.scroll:GetCanvas()
    canvas:DockPadding(0, 0, 0, 12)
    canvas.Paint = function() end
    self.content = canvas
    local function tryGenerate()
        if not IsValid(self) then return end
        local char = LocalPlayer():getChar()
        if char and not table.IsEmpty(self.CharacterInformation or {}) then
            self:Refresh()
        else
            timer.Simple(0.1, tryGenerate)
        end
    end

    timer.Simple(0.1, tryGenerate)
    timer.Create("liaCharInfo_UpdateValues", 1, 0, function()
        if IsValid(self) then
            self:setup()
        else
            timer.Remove("liaCharInfo_UpdateValues")
        end
    end)
end

function PANEL:CreateStatCard(parent, title, icon, valueFunc)
    local card = parent:Add("DPanel")
    card.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 9, Color(9, 24, 29, 238), Color(accent.r, accent.g, accent.b, 80))
        drawIcon(icon, 22, 20, 40, accent)
        draw.SimpleText(string.upper(title), "LiliaFont.17", 76, 28, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(valueFunc() or "", "LiliaFont.25", 22, h - 60, Color(242, 247, 247), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    return card
end

function PANEL:GetRankText()
    local client = LocalPlayer()
    local char = client:getChar()
    local rank = getFieldValue(self, "rank")
    if rank == "" and char then
        local storedRank = char.getData and char:getData("rank")
        if storedRank ~= nil and tostring(storedRank) ~= "" then rank = tostring(storedRank) end
    end

    if rank == "" then
        local userGroup = client:GetUserGroup()
        if isstring(userGroup) and userGroup ~= "" then
            rank = userGroup:gsub("_", " ")
            rank = rank:sub(1, 1):upper() .. rank:sub(2)
        end
    end

    if rank == "" then rank = L("none") end
    return rank
end

function PANEL:CreateIdentityAction(parent, width, icon, title, value, doClick)
    local panelType = isfunction(doClick) and "DButton" or "DPanel"
    local action = parent:Add(panelType)
    action:Dock(LEFT)
    action:SetWide(width)
    action:DockMargin(0, 0, 12, 0)
    if action.SetText then action:SetText("") end
    action.Paint = function(s, w, h)
        local accent = getThemeColors()
        local hovered = s.IsHovered and s:IsHovered() or false
        local borderAlpha = hovered and 100 or 60
        local background = hovered and Color(16, 34, 40, 235) or Color(13, 30, 35, 225)
        drawPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, borderAlpha))
        if title ~= "" then
            draw.SimpleText(title, "LiliaFont.16", 16, 8, Color(165, 187, 188), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(value or "", "LiliaFont.18", 16, h - 8, Color(230, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        else
            draw.SimpleText(value or "", "LiliaFont.18", 16, h * 0.5, Color(230, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    if isfunction(doClick) then action.DoClick = doClick end
    return action
end

function PANEL:BuildIdentity()
    local client = LocalPlayer()
    local char = client:getChar()
    if not char then return end
    self.characterName:SetText(char:getName() or L("unknown"))
    self.characterSubtitle:SetText("")
    self.characterSubtitle:SetVisible(false)
    self.chips:Clear()
    self:CreateIdentityAction(self.chips, 196, Material("icon16/shield.png", "smooth"), L("rank"), self:GetRankText())
    self:CreateIdentityAction(self.chips, 224, Material("icon16/world_link.png", "smooth"), "", "Steam Profile", function()
        local steamID64 = client:SteamID64()
        if steamID64 and steamID64 ~= "" then gui.OpenURL("https://steamcommunity.com/profiles/" .. steamID64) end
    end)

    self:CreateIdentityAction(self.chips, 190, Material("icon16/page_copy.png", "smooth"), "", "Copy SteamID", function()
        local steamID = client:SteamID()
        if steamID and steamID ~= "" then SetClipboardText(steamID) end
    end)

    self:CreateIdentityAction(self.chips, 210, Material("icon16/page_copy.png", "smooth"), "", "Copy SteamID64", function()
        local steamID64 = client:SteamID64()
        if steamID64 and steamID64 ~= "" then SetClipboardText(steamID64) end
    end)
end

function PANEL:CreateTextEntryWithBackgroundAndLabel(parent, name, labelText, marginBot, valueFunc, icon)
    local entry = parent:Add("DPanel")
    entry:Dock(FILL)
    local contentX = 18
    entry.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(10, 25, 30, 232), Color(accent.r, accent.g, accent.b, 45))
    end

    local lbl = entry:Add("DLabel")
    lbl:SetFont("LiliaFont.17")
    lbl:SetText(labelText or "")
    lbl:SetTextColor(Color(165, 187, 188))
    lbl:SetPos(contentX, 13)
    lbl:SetSize(260, 22)
    local txt = entry:Add("DTextEntry")
    txt:SetPos(contentX, 39)
    txt:SetTall(30)
    txt:SetFont("LiliaFont.18")
    txt:SetTextColor(Color(230, 239, 239))
    txt:SetCursorColor(getThemeColors())
    txt:SetDrawBackground(false)
    txt:SetPaintBackground(false)
    txt:SetPaintBorderEnabled(false)
    local isDesc = (name or ""):lower() == "desc"
    txt:SetEditable(isDesc)
    if isfunction(valueFunc) then
        local value = valueFunc()
        if value ~= nil then txt:SetValue(tostring(value)) end
    end

    entry.PerformLayout = function(s) txt:SetWide(math.max(s:GetWide() - contentX - 16, 80)) end
    local function submitDescription()
        if not isDesc then return end
        local value = txt:GetValue()
        if not isstring(value) then return end
        if txt.lastValue == value then return end
        local trimmedValue = string.Trim(value)
        local valueWithoutSpaces = string.gsub(trimmedValue, "%s", "")
        local minLength = lia.config.get("MinDescLen", 16)
        if #valueWithoutSpaces < minLength then
            local now = CurTime()
            txt.lastErrorTime = txt.lastErrorTime or 0
            if now - txt.lastErrorTime > 1 then
                LocalPlayer():notifyErrorLocalized("descMinLen", minLength)
                txt.lastErrorTime = now
            end
            return
        end

        txt.lastValue = value
        lia.command.send("chardesc", value)
    end

    txt.OnEnter = submitDescription
    txt.OnLoseFocus = submitDescription
    self[name] = txt
    self.cards[#self.cards + 1] = entry
end

function PANEL:CreateFillableBarWithBackgroundAndLabel(parent, name, labelText, minFunc, maxFunc, margin, valueFunc, icon)
    local entry = parent:Add("DPanel")
    entry:Dock(FILL)
    local contentX = 16
    entry.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(10, 25, 30, 232), Color(accent.r, accent.g, accent.b, 45))
        draw.SimpleText(labelText or "", "LiliaFont.17", contentX, 12, Color(165, 187, 188), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local bar = entry:Add("liaProgressBar")
    bar:SetPos(contentX, 45)
    bar:SetTall(22)
    entry.PerformLayout = function(s) bar:SetWide(math.max(s:GetWide() - contentX - 16, 80)) end
    bar:SetBarColor(getThemeColors())
    bar.Think = function(barSelf)
        local mn = isfunction(minFunc) and minFunc() or tonumber(minFunc) or 0
        local mx = isfunction(maxFunc) and maxFunc() or tonumber(maxFunc) or 1
        local val = isfunction(valueFunc) and valueFunc() or tonumber(valueFunc) or 0
        barSelf:SetFraction(mx > mn and math.Clamp((val - mn) / (mx - mn), 0, 1) or 0)
        barSelf:SetText(L("barProgress", math.Round(val), math.Round(mx)))
    end

    parent[name] = bar
    self.cards[#self.cards + 1] = entry
    return bar
end

function PANEL:GenerateSections()
    self.cards = {}
    if table.IsEmpty(self.CharacterInformation) then return end
    local sections = {}
    for name, data in pairs(self.CharacterInformation) do
        sections[#sections + 1] = {
            name = name,
            data = data
        }
    end

    local fieldOrder = {
        name = 1,
        desc = 2,
        description = 2,
        money = 3,
        playtime = 4,
        faction = 5,
        class = 6
    }

    table.sort(sections, function(a, b) return a.data.priority < b.data.priority end)
    for _, section in ipairs(sections) do
        local fields = isfunction(section.data.fields) and section.data.fields() or section.data.fields
        local visibleFields = {}
        for index, field in ipairs(fields or {}) do
            local normalizedName = normalizeCharInfoSectionName(field.name or "")
            if hook.Run("CanDisplayCharInfo", field.name) ~= false then
                visibleFields[#visibleFields + 1] = {
                    field = field,
                    index = index,
                    order = fieldOrder[normalizedName] or 1000 + index
                }
            end
        end

        table.sort(visibleFields, function(a, b)
            if a.order == b.order then return a.index < b.index end
            return a.order < b.order
        end)

        local fieldCount = #visibleFields
        if fieldCount > 0 then
            local frame = self.content:Add("DPanel")
            frame:Dock(TOP)
            frame:DockMargin(0, 0, 0, 14)
            frame:DockPadding(14, 50, 14, 14)
            frame.Paint = function(_, w, h)
                local accent = getThemeColors()
                drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
                draw.SimpleText(string.upper(L(section.name)), "LiliaFont.18", 17, 14, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local grid = frame:Add("DPanel")
            grid:Dock(FILL)
            grid.cards = {}
            grid.Paint = function() end
            for _, fieldData in ipairs(visibleFields) do
                local field = fieldData.field
                local holder = grid:Add("DPanel")
                holder.Paint = function() end
                grid.cards[#grid.cards + 1] = holder
                if field.type == "text" then
                    self:CreateTextEntryWithBackgroundAndLabel(holder, field.name, L(field.label or ""), 0, field.value, field.icon)
                elseif field.type == "bar" then
                    self:CreateFillableBarWithBackgroundAndLabel(holder, field.name, L(field.label or ""), field.min, field.max, 0, field.value, field.icon)
                end
            end

            grid.PerformLayout = function(s, w)
                local gapX = 12
                local gapY = 10
                local cardH = 82
                local columns = w >= 640 and 2 or 1
                local cardW = columns == 2 and math.floor((w - gapX) * 0.5) or w
                for i, card in ipairs(s.cards) do
                    local index = i - 1
                    local column = index % columns
                    local row = math.floor(index / columns)
                    card:SetPos(column * (cardW + gapX), row * (cardH + gapY))
                    card:SetSize(cardW, cardH)
                end
            end

            frame.PerformLayout = function(s, w)
                local innerW = math.max(w - 28, 1)
                local columns = innerW >= 640 and 2 or 1
                local rows = math.max(math.ceil(fieldCount / columns), 1)
                local cardH = 82
                local gapY = 10
                s:SetTall(64 + rows * cardH + math.max(rows - 1, 0) * gapY)
            end
        end
    end
end

function PANEL:OnRemove()
    hook.Remove("OnThemeChanged", self)
end

function PANEL:OnThemeChanged()
    if IsValid(self) then self:Refresh() end
end

function PANEL:Refresh()
    self:ApplyCurrentTheme()
    self.content:Clear()
    self:BuildIdentity()
    self:GenerateSections()
    self:setup()
end

function PANEL:ApplyCurrentTheme()
    local currentTheme = lia.color.getCurrentTheme()
    if currentTheme and lia.color.themes[currentTheme] then lia.color.theme = table.Copy(lia.color.themes[currentTheme]) end
end

function PANEL:setup()
    if table.IsEmpty(self.CharacterInformation) then return end
    self:BuildIdentity()
    for _, data in pairs(self.CharacterInformation) do
        local fields = isfunction(data.fields) and data.fields() or data.fields
        for _, field in ipairs(fields or {}) do
            local ctrl = self[field.name]
            if ctrl and field.type == "text" and field.name:lower() ~= "desc" then
                local value = isfunction(field.value) and field.value() or field.value
                ctrl:SetValue(value ~= nil and tostring(value) or "")
            end
        end
    end
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")
PANEL = {}
function PANEL:Init()
    lia.gui.menu = self
    hook.Run("F1MenuOpened", self)
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetPopupStayAtBack(true)
    self.noAnchor = CurTime() + 0.4
    self.anchorMode = true
    self.invKey = lia.keybind.get(L("openInventory"), KEY_I)
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    hook.Add("AdminPrivilegesUpdated", self, self.OnAdminPrivilegesUpdated)
    self.topBar = self:Add("DPanel")
    self.topBar:Dock(TOP)
    self.topBar:SetTall(74)
    local schemaIconMat = SCHEMA and SCHEMA.icon and Material(SCHEMA.icon, "smooth") or Material("lilia.png", "smooth")
    local schemaName = SCHEMA and SCHEMA.name or "Mojave Reborn"
    self.topBar.Paint = function(_, w, h)
        local accent = getThemeColors()
        surface.SetDrawColor(4, 13, 17, 250)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(0, 0, w, 1)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 185)
        surface.DrawRect(0, h - 2, w, 2)
    end

    self.brandPanel = self.topBar:Add("DPanel")
    self.brandPanel:SetSize(420, 58)
    self.brandPanel.Paint = function(_, w, h)
        surface.SetMaterial(schemaIconMat)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.DrawTexturedRect(0, 6, 46, 46)
        draw.SimpleText(L(schemaName), "LiliaFont.25", 58, h * 0.5, Color(244, 248, 248), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.headerUtility = self.topBar:Add("DPanel")
    self.headerUtility:SetTall(50)
    self.headerUtility:SetZPos(50)
    self.headerUtility.Paint = function() end
    self.statusGroup = self.topBar:Add("DPanel")
    self.statusGroup:SetSize(380, 50)
    self.statusGroup.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 7, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 70))
        surface.SetDrawColor(255, 255, 255, 18)
        surface.DrawRect(150, 9, 1, h - 18)
    end

    self.onlineDot = self.statusGroup:Add("DPanel")
    self.onlineDot:SetSize(12, 12)
    self.onlineDot.Paint = function(_, w, h)
        local accent = getThemeColors()
        draw.RoundedBox(math.floor(w * 0.5), 0, 0, w, h, Color(accent.r, accent.g, accent.b, 245))
    end

    self.onlineLabel = self.statusGroup:Add("DLabel")
    self.onlineLabel:SetFont("LiliaFont.17")
    self.onlineLabel:SetTextColor(Color(220, 232, 232))
    self.onlineLabel:SetContentAlignment(4)
    self.onlineLabel:SetTall(50)
    self.timeIcon = self.statusGroup:Add("DPanel")
    self.timeIcon:SetSize(22, 50)
    self.timeIcon.Paint = function(_, _, h) drawIcon(Material("icon16/time.png", "smooth"), 1, math.floor(h * 0.5) - 8, 16, Color(185, 203, 203)) end
    self.timeLabel = self.statusGroup:Add("DLabel")
    self.timeLabel:SetFont("LiliaFont.17")
    self.timeLabel:SetTextColor(Color(220, 232, 232))
    self.timeLabel:SetContentAlignment(4)
    self.timeLabel:SetTall(50)
    self.statusGroup.PerformLayout = function(_, w, h)
        local onlineSectionWidth = 150
        local timeSectionWidth = w - onlineSectionWidth
        local onlineGap = 8
        surface.SetFont("LiliaFont.17")
        local onlineTextWidth = select(1, surface.GetTextSize(self.onlineLabel:GetText()))
        self.onlineLabel:SetWide(onlineTextWidth)
        local onlineWidth = self.onlineDot:GetWide() + onlineGap + onlineTextWidth
        local onlineX = math.floor((onlineSectionWidth - onlineWidth) * 0.5)
        self.onlineDot:SetPos(onlineX, math.floor((h - self.onlineDot:GetTall()) * 0.5))
        self.onlineLabel:SetPos(onlineX + self.onlineDot:GetWide() + onlineGap, 0)
        local timeGap = 10
        local timeTextWidth = select(1, surface.GetTextSize(self.timeLabel:GetText()))
        self.timeLabel:SetWide(timeTextWidth)
        local timeWidth = self.timeIcon:GetWide() + timeGap + timeTextWidth
        local timeX = onlineSectionWidth + math.floor((timeSectionWidth - timeWidth) * 0.5)
        self.timeIcon:SetPos(timeX, 0)
        self.timeLabel:SetPos(timeX + self.timeIcon:GetWide() + timeGap, 0)
    end

    self.utilityGroup = self.headerUtility:Add("DPanel")
    self.utilityGroup:Dock(FILL)
    self.utilityGroup:DockPadding(5, 3, 5, 3)
    self.utilityGroup.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 7, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 70))
    end

    local utilityButtons = {
        {
            key = "characters",
            icon = "icon16/user.png",
            tooltip = "characters"
        },
        {
            key = "@logs",
            icon = "icon16/book_open.png",
            tooltip = "@logs"
        },
        {
            key = "@information",
            icon = "icon16/information.png",
            tooltip = "@information"
        },
        {
            key = "@settings",
            icon = "icon16/cog.png",
            tooltip = "@settings"
        },
        {
            key = "@themes",
            icon = "icon16/color_wheel.png",
            tooltip = "@themes"
        }
    }

    self.utilityButtons = {}
    for _, data in ipairs(utilityButtons) do
        local key = data.key
        local button = self.utilityGroup:Add("DButton")
        button:Dock(LEFT)
        button:SetWide(44)
        button:DockMargin(0, 0, 5, 0)
        button:SetText("")
        button:SetTooltip(localizeMenuLabel(data.tooltip))
        button._key = key
        button._icon = Material(data.icon, "smooth")
        button.Paint = function(s, w, h)
            local accent = getThemeColors()
            local active = self.activeTabKey == s._key
            local hovered = s:IsHovered()
            if active or hovered then
                local background = active and Color(accent.r, accent.g, accent.b, 30) or Color(255, 255, 255, 6)
                local outline = active and Color(accent.r, accent.g, accent.b, 110) or Color(accent.r, accent.g, accent.b, 55)
                drawPanel(0, 0, w, h, 6, background, outline)
            end

            drawIcon(s._icon, math.floor((w - 22) * 0.5), math.floor((h - 22) * 0.5), 22, active and Color(244, 248, 248) or hovered and Color(220, 232, 232) or Color(175, 195, 195))
        end

        button.DoClick = function() if self.tabList and self.tabList[key] then self:setActiveTab(key) end end
        self.utilityButtons[#self.utilityButtons + 1] = button
    end

    function self:RefreshUtilityButtons()
        local visibleCount = 0
        for _, button in ipairs(self.utilityButtons or {}) do
            if IsValid(button) then
                local shouldShow = button._key == "characters" or self.tabList and self.tabList[button._key] ~= nil
                button:SetVisible(shouldShow)
                if shouldShow then visibleCount = visibleCount + 1 end
            end
        end

        self._visibleUtilityButtonCount = visibleCount
        if IsValid(self.topBar) then self.topBar:InvalidateLayout(true) end
    end

    self.headerUtility.Think = function()
        local changed = false
        if IsValid(self.onlineLabel) then
            local onlineText = #player.GetAll() .. " " .. L("online")
            if self.onlineLabel:GetText() ~= onlineText then
                self.onlineLabel:SetText(onlineText)
                changed = true
            end
        end

        if IsValid(self.timeLabel) then
            local timeText = L("serverTime") .. ": " .. os.date("%H:%M")
            if self.timeLabel:GetText() ~= timeText then
                self.timeLabel:SetText(timeText)
                changed = true
            end
        end

        if changed and IsValid(self.statusGroup) then self.statusGroup:InvalidateLayout(true) end
    end

    self.tabs = self.topBar:Add("liaTabs")
    self.tabs:SetSize(1, 1)
    self.tabs:SetPos(-8, -8)
    self.tabs:SetVisible(false)
    self.tabs:SetMouseInputEnabled(false)
    self.tabs:SetKeyboardInputEnabled(false)
    self.topBar.PerformLayout = function(_, w, h)
        self.brandPanel:SetPos(26, math.floor((h - self.brandPanel:GetTall()) * 0.5))
        self.statusGroup:SetPos(math.floor((w - self.statusGroup:GetWide()) * 0.5), math.floor((h - self.statusGroup:GetTall()) * 0.5))
        local utilityButtonCount = self._visibleUtilityButtonCount or #utilityButtons
        local utilityWidth = utilityButtonCount > 0 and 5 + utilityButtonCount * 49 + 5 or 0
        self.headerUtility:SetSize(utilityWidth, 50)
        self.headerUtility:SetPos(w - utilityWidth - 22, math.floor((h - 50) * 0.5))
    end

    self.body = self:Add("DPanel")
    self.body:Dock(FILL)
    self.body:DockMargin(0, 18, 0, 22)
    self.body.Paint = function() end
    self.sidebar = self.body:Add("DPanel")
    self.sidebar:Dock(LEFT)
    self.sidebar:SetWide(math.Clamp(ScrW() * 0.15, 242, 272))
    self.sidebar:DockMargin(26, 0, 16, 0)
    self.sidebar:DockPadding(12, 14, 12, 14)
    self.sidebar.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 10, Color(7, 20, 25, 237), Color(accent.r, accent.g, accent.b, 78))
    end

    self.sidebarScroll = self.sidebar:Add("liaScrollPanel")
    self.sidebarScroll:Dock(FILL)
    self.sidebarScroll.Paint = function() end
    self.sidebarCanvas = self.sidebarScroll:GetCanvas()
    if IsValid(self.sidebarCanvas) then
        self.sidebarCanvas:DockPadding(0, 0, 4, 0)
        self.sidebarCanvas.Paint = function() end
    end

    self.panelWrapper = self.body:Add("EditablePanel")
    self.panelWrapper:Dock(FILL)
    self.panelWrapper:DockMargin(0, 0, 26, 0)
    self.panelWrapper:DockPadding(18, 18, 18, 18)
    self.panelWrapper.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 10, Color(6, 18, 23, 226), Color(accent.r, accent.g, accent.b, 72))
    end

    self.panel = self.panelWrapper:Add("EditablePanel")
    self.panel:Dock(FILL)
    self.panel.Paint = function() end
    local btnDefs = {}
    hook.Run("CreateMenuButtons", btnDefs)
    for key, value in pairs(btnDefs) do
        if isfunction(value) then
            btnDefs[key] = {
                name = key,
                func = value
            }
        end
    end

    local tabKeys = {}
    for key in pairs(btnDefs) do
        tabKeys[#tabKeys + 1] = key
    end

    table.sort(tabKeys, function(a, b) return tostring(localizeMenuLabel(btnDefs[a].name)):lower() < tostring(localizeMenuLabel(btnDefs[b].name)):lower() end)
    self.tabList = {}
    self._tabIndex = {}
    self.sidebarButtons = {}
    local tabIndex = 0
    for _, key in ipairs(tabKeys) do
        local tabDef = btnDefs[key]
        if tabDef.shouldShow and not tabDef.shouldShow() then continue end
        tabDef.name = tabDef.name or key
        local callback = tabDef.func
        if isstring(callback) then
            local body = callback
            callback = function(parent)
                local html = parent:Add("DHTML")
                html:Dock(FILL)
                if body:sub(1, 4) == "http" then
                    html:OpenURL(body)
                else
                    html:SetHTML(body)
                end
            end
        end

        tabIndex = tabIndex + 1
        self._tabIndex[key] = tabIndex
        self.tabList[key] = self:addTab(key, tabDef.name, callback)
        if key ~= "@settings" and key ~= "@information" and key ~= "@admin" and key ~= "@logs" and key ~= "@themes" and key ~= "characters" then self:AddSidebarButton(key, tabDef.name, tabDef.icon) end
    end

    self.adminSidebarPages = {}
    self.adminSidebarButtons = {}
    self:RefreshUtilityButtons()
    if self.tabList["@admin"] then
        local adminPages = {}
        hook.Run("PopulateAdminTabs", adminPages)
        for i = #adminPages, 1, -1 do
            if adminPages[i].shouldShow and not adminPages[i].shouldShow() then table.remove(adminPages, i) end
        end

        if #adminPages > 0 then
            table.sort(adminPages, function(a, b)
                local an = tostring(localizeMenuLabel(a.name)):lower()
                local bn = tostring(localizeMenuLabel(b.name)):lower()
                return an < bn
            end)

            table.insert(adminPages, 1, {
                name = "onlineStaff",
                icon = "icon16/user.png"
            })

            self.adminSidebarPages = adminPages
            self:AddSidebarSectionLabel("ADMIN TOOLS")
            for i, page in ipairs(adminPages) do
                self:AddAdminSidebarButton(i, page)
            end
        end
    end

    self:MakePopup()
    local defaultTab = lia.config.get("DefaultMenuTab", "@you")
    if not self.tabList[defaultTab] then defaultTab = self.tabList["@you"] and "@you" or tabKeys[1] end
    if defaultTab then self:setActiveTab(defaultTab) end
    timer.Simple(0.1, function() if IsValid(self) then self:UpdateTabColors() end end)
end

function PANEL:AddSidebarButton(key, name, icon)
    local parent = IsValid(self.sidebarCanvas) and self.sidebarCanvas or self.sidebar
    local button = parent:Add("DButton")
    button:Dock(TOP)
    button:SetTall(52)
    button:DockMargin(0, 0, 0, 7)
    button:SetText("")
    button._key = key
    local localizedName = tostring(localizeMenuLabel(name))
    button._label = string.upper(localizedName)
    button._icon = resolveIconMaterial(icon, sidebarIcons[key] or Material("icon16/bullet_white.png", "smooth"))
    button:SetTooltip(localizedName)
    button.Paint = function(s, w, h)
        local accent = getThemeColors()
        local active = self.activeTabKey == s._key
        local hovered = s:IsHovered()
        local bg = active and Color(accent.r, accent.g, accent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(0, 0, 0, 0)
        drawPanel(0, 0, w, h, 7, bg, active and Color(accent.r, accent.g, accent.b, 120) or nil)
        if active then
            surface.SetDrawColor(accent.r, accent.g, accent.b, 240)
            surface.DrawRect(0, 7, 3, h - 14)
        end

        drawIcon(s._icon, 16, 14, 24, active and Color(245, 249, 249) or Color(165, 186, 186))
        draw.SimpleText(s._label, "LiliaFont.17", 54, h * 0.5, active and Color(245, 249, 249) or Color(191, 207, 207), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    button.DoClick = function()
        lia.websound.playButtonSound()
        self:setActiveTab(key)
    end

    self.sidebarButtons[#self.sidebarButtons + 1] = button
end

function PANEL:AddSidebarSectionLabel(label)
    local parent = IsValid(self.sidebarCanvas) and self.sidebarCanvas or self.sidebar
    local section = parent:Add("DPanel")
    section:Dock(TOP)
    section:SetTall(38)
    section:DockMargin(0, 8, 0, 4)
    section.Paint = function(_, w, h)
        local accent = getThemeColors()
        draw.SimpleText(label, "LiliaFont.15", 4, h * 0.5, Color(accent.r, accent.g, accent.b, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 28)
        surface.DrawRect(4, h - 1, w - 8, 1)
    end
    return section
end

function PANEL:AddAdminSidebarButton(index, page)
    local parent = IsValid(self.sidebarCanvas) and self.sidebarCanvas or self.sidebar
    local button = parent:Add("DButton")
    button:Dock(TOP)
    button:SetTall(52)
    button:DockMargin(0, 0, 0, 7)
    button:SetText("")
    button._adminPageIndex = index
    button._label = tostring(localizeMenuLabel(page.name))
    button._icon = resolveIconMaterial(page.icon, Material("icon16/wrench.png", "smooth"))
    button:SetTooltip(button._label)
    button.Paint = function(s, w, h)
        local accent = getThemeColors()
        local active = self.activeTabKey == "@admin" and self.activeAdminPageIndex == s._adminPageIndex
        local hovered = s:IsHovered()
        local bg = active and Color(accent.r, accent.g, accent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(0, 0, 0, 0)
        drawPanel(0, 0, w, h, 7, bg, active and Color(accent.r, accent.g, accent.b, 120) or nil)
        if active then
            surface.SetDrawColor(accent.r, accent.g, accent.b, 240)
            surface.DrawRect(0, 7, 3, h - 14)
        end

        drawIcon(s._icon, 16, 14, 24, active and Color(245, 249, 249) or Color(165, 186, 186))
        draw.SimpleText(s._label, "LiliaFont.17", 54, h * 0.5, active and Color(245, 249, 249) or Color(191, 207, 207), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    button.DoClick = function()
        lia.websound.playButtonSound()
        self:OpenAdminPage(index)
    end

    self.adminSidebarButtons[#self.adminSidebarButtons + 1] = button
end

function PANEL:OpenAdminPage(index)
    index = tonumber(index)
    if not index or not self.adminSidebarPages or not self.adminSidebarPages[index] then return end
    self.pendingAdminPageIndex = index
    self.activeAdminPageIndex = index
    if self.activeTabKey ~= "@admin" then
        self:setActiveTab("@admin")
        return
    end

    if IsValid(self.panel) and isfunction(self.panel._openAdminPage) then self.panel._openAdminPage(index) end
    self:UpdateTabColors()
end

function PANEL:SwitchTabContent(name, callback)
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    if not callback or not IsValid(self.panelWrapper) then return end
    local wrapper = self.panelWrapper
    local oldPanel = self.panel
    wrapper:InvalidateLayout(true)
    if wrapper.PerformLayout then wrapper:PerformLayout() end
    local w, h = math.max(wrapper:GetWide() - 36, 1), math.max(wrapper:GetTall() - 36, 1)
    local oldKey = self.activeTabKey
    local oldIndex = oldKey and self._tabIndex[oldKey]
    local newIndex = self._tabIndex[name]
    local dir = oldIndex and newIndex and newIndex < oldIndex and -1 or 1
    local newPanel = wrapper:Add("EditablePanel")
    newPanel:SetSize(w, h)
    newPanel:SetPos(18 + dir * w, 18)
    newPanel:SetAlpha(0)
    newPanel.Paint = function() end
    self.panel = newPanel
    self.activeTabKey = name
    self:UpdateTabColors()
    self:ApplyCurrentTheme()
    callback(newPanel)
    newPanel:InvalidateLayout(true)
    local duration = 0.28
    if IsValid(oldPanel) then
        oldPanel:Dock(NODOCK)
        oldPanel:MoveTo(18 - dir * w, 18, duration, 0, 0.2, function() if IsValid(oldPanel) then oldPanel:Remove() end end)
        oldPanel:AlphaTo(0, duration, 0)
    end

    newPanel:MoveTo(18, 18, duration, 0, 0.2, function() if IsValid(newPanel) then newPanel:Dock(FILL) end end)
    newPanel:AlphaTo(255, duration, 0)
end

function PANEL:addTab(key, name, callback)
    local contentPanel = vgui.Create("EditablePanel")
    contentPanel:Dock(FILL)
    contentPanel.Paint = function() end
    self.tabs:AddTab(localizeMenuLabel(name), contentPanel, nil, function() self:SwitchTabContent(key, callback) end)
    local tabData = {
        name = name,
        panel = contentPanel,
        callback = callback
    }

    self.tabList = self.tabList or {}
    self.tabList[key] = tabData
    return tabData
end

function PANEL:setActiveTab(key)
    local tabData = self.tabList[key]
    if tabData and IsValid(tabData.panel) then
        for i, tabInfo in ipairs(self.tabs.tabs) do
            if tabInfo.pan == tabData.panel then
                self.tabs:SetActiveTab(i)
                return
            end
        end
    end
end

function PANEL:remove()
    CloseDermaMenus()
    if not self.closing then
        self:AlphaTo(0, 0.25, 0, function() self:Remove() end)
        self.closing = true
    end
end

function PANEL:OnRemove()
    hook.Run("F1MenuClosed")
    hook.Remove("OnThemeChanged", self)
    hook.Remove("AdminPrivilegesUpdated", self)
end

function PANEL:OnThemeChanged()
    if IsValid(self) then self:UpdateTabColors() end
end

function PANEL:OnAdminPrivilegesUpdated()
    if not IsValid(self) or self.closing then return end
    local client = LocalPlayer()
    if not IsValid(client) or not client:getChar() then return end
    if timer.Exists("liaF1AdminPrivilegesRefresh") then timer.Remove("liaF1AdminPrivilegesRefresh") end
    timer.Create("liaF1AdminPrivilegesRefresh", 0, 1, function()
        if not IsValid(self) or self.closing then return end
        self:RefreshUtilityButtons()
        self:UpdateTabColors()
    end)
end

function PANEL:ApplyCurrentTheme()
    local currentTheme = lia.color.getCurrentTheme()
    if currentTheme and lia.color.themes[currentTheme] then lia.color.theme = table.Copy(lia.color.themes[currentTheme]) end
end

function PANEL:UpdateTabColors()
    for _, button in ipairs(self.sidebarButtons or {}) do
        if IsValid(button) then button:InvalidateLayout(true) end
    end

    for _, button in ipairs(self.adminSidebarButtons or {}) do
        if IsValid(button) then button:InvalidateLayout(true) end
    end
end

function PANEL:OnKeyCodePressed(key)
    self.noAnchor = CurTime() + 0.5
    if key == KEY_F1 or key == self.invKey then self:remove() end
end

function PANEL:Update()
    if self:IsVisible() and not self.closing then self:InvalidateLayout(true) end
end

function PANEL:Think()
    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then
        self:remove()
        return
    end

    if input.IsKeyDown(KEY_F1) and CurTime() > self.noAnchor and self.anchorMode then
        self.anchorMode = false
        lia.websound.playButtonSound("buttons/lightswitch2.wav")
    end

    if not self.anchorMode and not input.IsKeyDown(KEY_F1) and not IsValid(self.info) then self:remove() end
end

function PANEL:Paint()
    lia.util.drawBlackBlur(self, 1, 5, 255, 225)
    surface.SetDrawColor(0, 8, 10, 110)
    surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
end

vgui.Register("liaMenu", PANEL, "EditablePanel")
PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    local w, h = self:GetParent():GetSize()
    self:SetSize(w, h)
    self.selectedClassModels = self.selectedClassModels or {}
    self.tabList = {}
    self.classData = {}
    self.classFilter = "all"
    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:SetTall(76)
    self.header.Paint = function()
        local _, textColor = getThemeColors()
        draw.SimpleText("Classes", "LiliaFont.30", 8, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Browse and select an available class.", "LiliaFont.17", 8, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content.Paint = function() end
    self.classBrowser = self.content:Add("DPanel")
    self.classBrowser:Dock(LEFT)
    self.classBrowser:DockMargin(0, 0, 14, 0)
    self.classBrowser:DockPadding(12, 12, 12, 12)
    self.classBrowser.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    self.searchRow = self.classBrowser:Add("DPanel")
    self.searchRow:Dock(TOP)
    self.searchRow:SetTall(48)
    self.searchRow:DockMargin(0, 0, 0, 12)
    self.searchRow.Paint = function() end
    self.filterCombo = self.searchRow:Add("DComboBox")
    self.filterCombo:Dock(RIGHT)
    self.filterCombo:SetWide(138)
    self.filterCombo:DockMargin(10, 0, 0, 0)
    self.filterCombo:SetFont("LiliaFont.17")
    self.filterCombo:SetTextColor(Color(205, 220, 220))
    self.filterCombo:SetContentAlignment(4)
    self.filterCombo:SetValue("All Classes")
    self.filterCombo:AddChoice("All Classes", "all")
    self.filterCombo:AddChoice("Available", "available")
    self.filterCombo:AddChoice("Unavailable", "unavailable")
    self.filterCombo.OnSelect = function(_, _, _, data)
        self.classFilter = data or "all"
        self:RebuildClassList()
    end

    self.filterCombo.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 5, Color(5, 18, 23, 235), Color(accent.r, accent.g, accent.b, 92))
    end

    if IsValid(self.filterCombo.DropButton) then
        self.filterCombo.DropButton:SetWide(30)
        self.filterCombo.DropButton.Paint = function(_, panelW, panelH) draw.SimpleText("▼", "LiliaFont.17", panelW * 0.5, panelH * 0.5, Color(190, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    end

    self.searchWrap = self.searchRow:Add("DPanel")
    self.searchWrap:Dock(FILL)
    self.searchWrap:DockPadding(40, 0, 8, 0)
    self.searchWrap.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 5, Color(5, 18, 23, 235), Color(accent.r, accent.g, accent.b, 92))
        drawIcon(Material("icon16/magnifier.png", "smooth"), 14, math.floor(panelH * 0.5) - 8, 16, Color(155, 181, 182))
    end

    self.searchEntry = self.searchWrap:Add("DTextEntry")
    self.searchEntry:Dock(FILL)
    self.searchEntry:SetFont("LiliaFont.17")
    self.searchEntry:SetTextColor(Color(225, 236, 236))
    self.searchEntry:SetCursorColor(getThemeColors())
    self.searchEntry:SetPlaceholderText("Search classes...")
    self.searchEntry:SetDrawBackground(false)
    self.searchEntry:SetPaintBackground(false)
    self.searchEntry:SetPaintBorderEnabled(false)
    self.searchEntry.OnChange = function() self:RebuildClassList() end
    self.classList = self.classBrowser:Add("liaScrollPanel")
    self.classList:Dock(FILL)
    self.classList.Paint = function() end
    local classCanvas = self.classList:GetCanvas()
    if IsValid(classCanvas) then
        classCanvas:DockPadding(0, 0, 4, 0)
        classCanvas.Paint = function() end
    end

    self.previewPanel = self.content:Add("DPanel")
    self.previewPanel:Dock(RIGHT)
    self.previewPanel:DockMargin(0, 0, 0, 0)
    self.previewPanel:DockPadding(14, 14, 14, 14)
    self.previewPanel.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    self.previewHeader = self.previewPanel:Add("DPanel")
    self.previewHeader:Dock(TOP)
    self.previewHeader:SetTall(66)
    self.previewHeader.Paint = function()
        local _, textColor = getThemeColors()
        draw.SimpleText("Character Preview", "LiliaFont.25", 0, 0, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Preview this class appearance.", "LiliaFont.17", 0, 36, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    self.previewBody = self.previewPanel:Add("DPanel")
    self.previewBody:Dock(FILL)
    self.previewBody.Paint = function() end
    self.detailsPanel = self.content:Add("DPanel")
    self.detailsPanel:Dock(FILL)
    self.detailsPanel:DockPadding(14, 14, 14, 14)
    self.detailsPanel.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    self.content.PerformLayout = function(_, panelW)
        local browserW = math.Clamp(math.floor(panelW * 0.28), 280, 360)
        local previewW = math.Clamp(math.floor(panelW * 0.32), 320, 440)
        self.classBrowser:SetWide(browserW)
        self.previewPanel:SetWide(previewW)
    end

    self:loadClasses()
end

function PANEL:loadClasses()
    local client = LocalPlayer()
    self.classData = {}
    for _, cl in pairs(lia.class.list) do
        if cl.faction == client:Team() then self.classData[#self.classData + 1] = cl end
    end

    table.sort(self.classData, function(a, b) return L(a.name or "") < L(b.name or "") end)
    self:RebuildClassList()
end

function PANEL:RebuildClassList()
    if not IsValid(self.classList) then return end
    self.classList:Clear()
    self.tabList = {}
    local search = IsValid(self.searchEntry) and string.Trim(self.searchEntry:GetValue() or ""):lower() or ""
    local selectedButton
    local firstButton
    for _, cl in ipairs(self.classData or {}) do
        local className = cl.name and L(cl.name) or L("unnamed")
        local factionName = team.GetName(cl.faction) or L("none")
        local canBe = lia.class.canBe(LocalPlayer(), cl.index)
        local matchesSearch = search == "" or className:lower():find(search, 1, true) or tostring(factionName):lower():find(search, 1, true)
        local matchesFilter = self.classFilter == "all" or self.classFilter == "available" and canBe or self.classFilter == "unavailable" and not canBe
        if not matchesSearch or not matchesFilter then continue end
        local button = self.classList:Add("DButton")
        button:Dock(TOP)
        button:SetTall(56)
        button:DockMargin(0, 0, 0, 8)
        button:SetText("")
        button._classIndex = cl.index
        button._classData = cl
        button._className = className
        button._factionName = factionName
        button._canBe = canBe
        button._icon = resolveIconMaterial(cl.icon or cl.logo, canBe and Material("icon16/group.png", "smooth") or Material("icon16/lock.png", "smooth"))
        button.Paint = function(s, panelW, panelH)
            local accent = getThemeColors()
            local active = self.selectedClassIndex == s._classIndex
            local hovered = s:IsHovered()
            local bg = active and Color(accent.r, accent.g, accent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(2, 14, 18, 130)
            drawPanel(0, 0, panelW, panelH, 5, bg, active and Color(accent.r, accent.g, accent.b, 145) or Color(accent.r, accent.g, accent.b, 42))
            if active then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 245)
                surface.DrawRect(0, 7, 3, panelH - 14)
            end

            drawIcon(s._icon, 16, 16, 24, active and Color(240, 247, 247) or Color(175, 196, 196))
            draw.SimpleText(s._className, "LiliaFont.18", 54, 11, active and Color(244, 248, 248) or Color(220, 232, 232), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(s._factionName, "LiliaFont.15", 54, 33, s._canBe and accent or Color(135, 156, 157), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        button.DoClick = function()
            lia.websound.playButtonSound()
            local classData = button._classData
            self.selectedClassIndex = classData.index
            self:populateClassDetails(classData, lia.class.canBe(LocalPlayer(), classData.index))
        end

        self.tabList[#self.tabList + 1] = button
        if not firstButton then firstButton = button end
        if self.selectedClassIndex == cl.index then selectedButton = button end
    end

    local target = IsValid(selectedButton) and selectedButton or firstButton
    if IsValid(target) then
        timer.Simple(0, function() if IsValid(self) and IsValid(target) then target:DoClick() end end)
    else
        self.selectedClassIndex = nil
        if IsValid(self.detailsPanel) then self.detailsPanel:Clear() end
        if IsValid(self.previewBody) then self.previewBody:Clear() end
    end
end

function PANEL:populateClassDetails(cl, canBe)
    if not IsValid(self.detailsPanel) or not IsValid(self.previewBody) then return end
    self.detailsPanel:Clear()
    self.previewBody:Clear()
    local className = cl.name and L(cl.name) or L("unnamed")
    local description = cl.desc and L(cl.desc) or L("noDesc")
    local header = self.detailsPanel:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(124)
    header:DockMargin(0, 0, 0, 12)
    header:DockPadding(16, 14, 96, 14)
    header.Paint = function(_, panelW, panelH)
        local accent, textColor = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
        draw.SimpleText(className, "LiliaFont.25", 16, 15, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local desc = header:Add("DLabel")
    desc:Dock(FILL)
    desc:DockMargin(0, 34, 0, 0)
    desc:SetFont("LiliaFont.17")
    desc:SetText(description)
    desc:SetTextColor(Color(185, 204, 204))
    desc:SetWrap(true)
    desc:SetContentAlignment(7)
    if cl.logo then
        local logo = header:Add("DImage")
        logo:SetSize(72, 72)
        logo:SetImage(cl.logo)
        logo:SetKeepAspect(true)
        header.PerformLayout = function(_, panelW) logo:SetPos(panelW - 84, 24) end
    end

    local detailsScroll = self.detailsPanel:Add("liaScrollPanel")
    detailsScroll:Dock(FILL)
    detailsScroll.Paint = function() end
    local canvas = detailsScroll:GetCanvas()
    if IsValid(canvas) then
        canvas:DockPadding(0, 0, 4, 0)
        canvas.Paint = function() end
    end

    self:addClassDetails(IsValid(canvas) and canvas or detailsScroll, cl)
    local action = self.previewBody:Add("DPanel")
    action:Dock(BOTTOM)
    action:SetTall(142)
    action:DockMargin(0, 12, 0, 0)
    action:DockPadding(14, 14, 14, 14)
    action.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
    end

    self:addJoinButton(action, cl, canBe)
    self:createModelPanel(self.previewBody, cl)
end

function PANEL:createModelPanel(parent, cl)
    local container = parent:Add("DPanel")
    container:Dock(FILL)
    container.Paint = function(_, panelW, panelH)
        local accent = getThemeColors()
        drawPanel(0, 0, panelW, panelH, 6, Color(2, 14, 18, 175), Color(accent.r, accent.g, accent.b, 92))
    end

    local panel = container:Add("liaModelPanel")
    panel:Dock(FILL)
    panel:DockMargin(8, 8, 8, 8)
    panel:SetFOV(26)
    panel:SetAnimated(true)
    panel:SetAmbientLight(Color(120, 138, 148))
    panel:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    panel:SetDirectionalLight(BOX_FRONT, Color(220, 232, 232))
    panel:SetDirectionalLight(BOX_RIGHT, Color(90, 110, 118))
    panel:SetDirectionalLight(BOX_LEFT, Color(90, 110, 118))
    local function getModels(mdl)
        local models = {}
        if isstring(mdl) and mdl ~= "" then
            models[#models + 1] = mdl
        elseif istable(mdl) then
            local function gather(tbl)
                for _, value in pairs(tbl) do
                    if isstring(value) then
                        models[#models + 1] = value
                    elseif istable(value) then
                        gather(value)
                    end
                end
            end

            gather(mdl)
        end
        return models
    end

    local availableModels = getModels(cl.model or cl.models)
    if #availableModels == 0 then availableModels = {LocalPlayer():GetModel()} end
    panel.currentModelIndex = 1
    panel.availableModels = availableModels
    panel.classData = cl
    panel.rotationAngle = 0
    local function setIdleSequence(ent)
        if not IsValid(ent) then return end
        local sequences = {"idle_all_01", "idle_subtle", "idle_unarmed", "idle01", "pose_standing_01"}
        for _, sequenceName in ipairs(sequences) do
            local sequence = ent:LookupSequence(sequenceName)
            if sequence and sequence > 0 then
                ent:ResetSequence(sequence)
                ent:SetCycle(0)
                return
            end
        end
    end

    local function frameModel()
        local ent = panel.Entity
        if not IsValid(ent) then return end
        local mins, maxs = ent:GetRenderBounds()
        if not mins or not maxs then return end
        ent:SetPos(Vector(0, 0, -mins.z))
        mins, maxs = ent:GetRenderBounds()
        local size = maxs - mins
        local width = math.max(size.x, size.y, 1)
        local height = math.max(size.z, 1)
        local center = Vector((mins.x + maxs.x) * 0.5, (mins.y + maxs.y) * 0.5, -mins.z + height * 0.5)
        local fov = 24
        local aspect = math.max(panel:GetWide(), 1) / math.max(panel:GetTall(), 1)
        local verticalFov = math.deg(2 * math.atan(math.tan(math.rad(fov * 0.5)) / math.max(aspect, 0.1)))
        local verticalDistance = height * 0.55 / math.tan(math.rad(verticalFov * 0.5))
        local horizontalDistance = width * 0.6 / math.tan(math.rad(fov * 0.5))
        local distance = math.max(verticalDistance, horizontalDistance)
        panel:SetFOV(fov)
        panel:SetLookAt(center)
        panel:SetCamPos(center + Vector(distance, 0, 0))
    end

    local function updateModel()
        local model = panel.availableModels[panel.currentModelIndex]
        if util and util.IsValidModel and not util.IsValidModel(model) then model = LocalPlayer():GetModel() end
        panel:SetModel(model)
        self.selectedClassModels[cl.index] = model
        local function applyEntitySettings()
            local ent = panel.Entity
            if not IsValid(ent) then return end
            ent:SetSkin(panel.classData.skin or 0)
            ent:SetModelScale(tonumber(panel.classData.scale) or 1, 0)
            ent:SetAngles(Angle(0, panel.rotationAngle, 0))
            lia.util.applyBodygroups(ent, panel.classData.bodyGroups or panel.classData.bodygroups)
            for i, material in ipairs(panel.classData.subMaterials or {}) do
                ent:SetSubMaterial(i - 1, material)
            end

            setIdleSequence(ent)
            frameModel()
        end

        applyEntitySettings()
        timer.Simple(0, function() if IsValid(panel) then applyEntitySettings() end end)
        timer.Simple(0.05, function() if IsValid(panel) then applyEntitySettings() end end)
        timer.Simple(0.15, function() if IsValid(panel) then applyEntitySettings() end end)
    end

    updateModel()
    if #availableModels > 1 then
        local arrowSize = 34
        local function createArrow(text, direction)
            local button = container:Add("DButton")
            button:SetSize(arrowSize, arrowSize)
            button:SetText("")
            button.Paint = function(s, panelW, panelH)
                local accent = getThemeColors()
                drawPanel(0, 0, panelW, panelH, 4, s:IsHovered() and Color(accent.r, accent.g, accent.b, 30) or Color(2, 14, 18, 210), Color(accent.r, accent.g, accent.b, 100))
                draw.SimpleText(text, "LiliaFont.24", panelW * 0.5, panelH * 0.5 - 1, Color(220, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            button.DoClick = function()
                panel.currentModelIndex = panel.currentModelIndex + direction
                if panel.currentModelIndex < 1 then panel.currentModelIndex = #panel.availableModels end
                if panel.currentModelIndex > #panel.availableModels then panel.currentModelIndex = 1 end
                lia.websound.playButtonSound("buttons/button14.wav")
                updateModel()
            end
            return button
        end

        panel.leftArrow = createArrow("<", -1)
        panel.rightArrow = createArrow(">", 1)
        container.PerformLayout = function(_, panelW, panelH)
            panel.leftArrow:SetPos(10, math.floor((panelH - arrowSize) * 0.5))
            panel.rightArrow:SetPos(panelW - arrowSize - 10, math.floor((panelH - arrowSize) * 0.5))
        end
    end

    panel.LayoutEntity = function(_, ent)
        if not IsValid(ent) then return end
        if input.IsKeyDown(KEY_A) then
            panel.rotationAngle = panel.rotationAngle - 0.5
        elseif input.IsKeyDown(KEY_D) then
            panel.rotationAngle = panel.rotationAngle + 0.5
        end

        ent:SetAngles(Angle(0, panel.rotationAngle, 0))
        ent:SetPoseParameter("head_yaw", 0)
        ent:SetPoseParameter("head_pitch", 0)
        ent:SetPoseParameter("body_yaw", 0)
        ent:SetPoseParameter("aim_yaw", 0)
        ent:SetPoseParameter("aim_pitch", 0)
        ent:SetEyeTarget(panel:GetCamPos())
        ent:FrameAdvance(FrameTime())
    end
    return panel.availableModels[panel.currentModelIndex]
end

function PANEL:addClassDetails(parent, cl)
    local client = LocalPlayer()
    local maxHealth = client:GetMaxHealth()
    local maxArmor = client:GetMaxArmor()
    local maxJump = client:GetJumpPower()
    local runSpeed = lia.config.get("RunSpeed")
    local walkSpeed = lia.config.get("WalkSpeed")
    local function getWeaponNames(weaponsData)
        if isstring(weaponsData) then weaponsData = {weaponsData} end
        if not istable(weaponsData) then return {} end
        local classes = {}
        local function gather(tbl)
            for _, value in pairs(tbl) do
                if isstring(value) then
                    classes[#classes + 1] = value
                elseif istable(value) then
                    local className = value.class or value.weapon or value.name
                    if isstring(className) then classes[#classes + 1] = className end
                end
            end
        end

        gather(weaponsData)
        local names = {}
        for _, className in ipairs(classes) do
            local stored = weapons.GetStored and weapons.GetStored(className) or nil
            local printName = stored and (stored.PrintName or stored.Name) or nil
            names[#names + 1] = printName and tostring(printName) ~= "" and tostring(printName) or tostring(className)
        end
        return names
    end

    local bloodMap = {
        [-1] = L("bloodNo"),
        [0] = L("bloodRed"),
        [1] = L("bloodYellow"),
        [2] = L("bloodGreenRed"),
        [3] = L("bloodSparks"),
        [4] = L("bloodAntlion"),
        [5] = L("bloodZombie"),
        [6] = L("bloodAntlionBright")
    }

    local factionName = team.GetName(cl.faction) or L("none")
    local classWeapons = getWeaponNames(cl.weapons)
    local resolvedRunSpeed = cl.runSpeed and math.Round(runSpeed * cl.runSpeed) or runSpeed
    local resolvedWalkSpeed = cl.walkSpeed and math.Round(walkSpeed * cl.walkSpeed) or walkSpeed
    local resolvedJumpPower = cl.jumpPower and math.Round(maxJump * cl.jumpPower) or maxJump
    local sections = {
        {
            title = "GENERAL",
            rows = {{L("faction"), factionName}, {L("isDefault"), cl.isDefault and L("yes") or L("no")}}
        },
        {
            title = "ATTRIBUTES",
            rows = {{L("baseHealth"), tostring(cl.health or maxHealth)}, {L("baseArmor"), tostring(cl.armor or maxArmor)}, {L("runSpeed"), tostring(resolvedRunSpeed)}, {L("walkSpeed"), tostring(resolvedWalkSpeed)}, {L("jumpPower"), tostring(resolvedJumpPower)}, {L("modelScale"), tostring(cl.scale or 1)}}
        },
        {
            title = "EQUIPMENT",
            rows = {{L("weapons"), #classWeapons > 0 and table.concat(classWeapons, ", ") or L("none")}}
        },
        {
            title = "APPEARANCE",
            rows = {{L("bloodColor"), bloodMap[cl.bloodcolor] or L("bloodRed")}}
        }
    }

    for _, sectionData in ipairs(sections) do
        local section = parent:Add("DPanel")
        section:Dock(TOP)
        section:SetTall(44 + #sectionData.rows * 34)
        section:DockMargin(0, 0, 0, 10)
        section:DockPadding(12, 42, 12, 8)
        section.Paint = function(_, panelW, panelH)
            local accent = getThemeColors()
            drawPanel(0, 0, panelW, panelH, 5, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
            draw.SimpleText(sectionData.title, "LiliaFont.17", 14, 12, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
            surface.DrawRect(12, 36, panelW - 24, 1)
        end

        for _, rowData in ipairs(sectionData.rows) do
            local row = section:Add("DPanel")
            row:Dock(TOP)
            row:SetTall(34)
            row.Paint = function(_, panelW, panelH)
                draw.SimpleText(rowData[1], "LiliaFont.17", 0, panelH * 0.5, Color(185, 204, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(rowData[2], "LiliaFont.17", panelW, panelH * 0.5, Color(232, 240, 240), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(255, 255, 255, 10)
                surface.DrawRect(0, panelH - 1, panelW, 1)
            end
        end
    end
end

function PANEL:addJoinButton(parent, cl, canBe)
    local classModels = cl.model or cl.models
    local hasModelChoices = istable(classModels)
    local char = LocalPlayer():getChar()
    local isCurrent = char and char:getClass() == cl.index
    local isNonDefault = cl.isDefault == false
    local buttonText
    local titleText
    local subtitleText
    if isCurrent and hasModelChoices then
        titleText = "Current Class"
        subtitleText = "Choose another appearance for this class."
        buttonText = L("changeModel")
    elseif isCurrent then
        titleText = "Current Class"
        subtitleText = "Your character is already using this class."
        buttonText = L("alreadyInClass")
    elseif not canBe and isNonDefault then
        titleText = "Class Unavailable"
        subtitleText = "This class is not available for your character."
        buttonText = L("classRequirementsNotMet")
    else
        titleText = "Class Available"
        subtitleText = "Your character can join this class."
        buttonText = L("joinClass")
    end

    parent.PaintOver = function(_, panelW)
        local accent, textColor = getThemeColors()
        local available = canBe or isCurrent
        local icon = available and Material("icon16/accept.png", "smooth") or Material("icon16/lock.png", "smooth")
        drawIcon(icon, 14, 15, 18, available and accent or Color(145, 160, 160))
        draw.SimpleText(titleText, "LiliaFont.20", 42, 12, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(subtitleText, "LiliaFont.15", 14, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local button = parent:Add("DButton")
    button:Dock(BOTTOM)
    button:SetTall(44)
    button:SetText("")
    button.Paint = function(s, panelW, panelH)
        local accent = getThemeColors()
        local disabled = s:GetDisabled()
        local bg = disabled and Color(255, 255, 255, 5) or s:IsHovered() and Color(accent.r, accent.g, accent.b, 34) or Color(accent.r, accent.g, accent.b, 16)
        drawPanel(0, 0, panelW, panelH, 5, bg, disabled and Color(255, 255, 255, 20) or Color(accent.r, accent.g, accent.b, 145))
        draw.SimpleText(string.upper(buttonText), "LiliaFont.17", panelW * 0.5, panelH * 0.5, disabled and Color(105, 120, 120) or accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    button:SetDisabled((not canBe and not isCurrent) or isCurrent and not hasModelChoices)
    button.DoClick = function()
        lia.websound.playButtonSound()
        if isCurrent then
            if hasModelChoices then lia.command.send("beclass", cl.index, self.selectedClassModels and self.selectedClassModels[cl.index] or nil) end
            return
        end

        if not canBe then return end
        if hasModelChoices then
            lia.command.send("beclass", cl.index, self.selectedClassModels and self.selectedClassModels[cl.index] or nil)
        else
            lia.command.send("beclass", cl.index)
        end

        timer.Simple(0.1, function() if IsValid(self) then self:loadClasses() end end)
    end
end

vgui.Register("liaClasses", PANEL, "EditablePanel")
hook.Add("LoadCharInformation", "liaF1MenuGeneralInfo", function()
    hook.Run("AddSection", L("generalInfo"), Color(0, 0, 0), 1, 1)
    hook.Run("AddTextField", L("generalInfo"), "name", L("name"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getName() or L("unknown")
    end, "icon16/user.png")

    hook.Run("AddTextField", L("generalInfo"), "desc", L("desc"), function()
        local client = LocalPlayer()
        local char = client:getChar()
        return char and char:getDesc() or ""
    end, "icon16/page_white_text.png")

    hook.Run("AddTextField", L("generalInfo"), "money", L("money"), function()
        local client = LocalPlayer()
        return client and lia.currency.get(client:getChar():getMoney()) or lia.currency.get(0)
    end, "icon16/money.png")

    hook.Run("AddTextField", L("generalInfo"), "playTime", L("playtime"), function()
        local client = LocalPlayer()
        return client and lia.time.formatDHM(client:getPlayTime()) or L("loading")
    end, "icon16/time.png")
end)

hook.Add("AddSection", "liaF1MenuAddSection", function(sectionName, color, priority, location)
    if IsValid(lia.gui.info) then
        local localizedSectionName = resolveCharInfoSectionName(sectionName)
        if not lia.gui.info.CharacterInformation[localizedSectionName] then
            lia.gui.info.CharacterInformation[localizedSectionName] = {
                fields = {},
                color = color or Color(255, 255, 255),
                priority = priority or 999,
                location = location or 1
            }
        else
            local info = lia.gui.info.CharacterInformation[localizedSectionName]
            info.color = color or info.color
            info.priority = priority or info.priority
            info.location = location or info.location
        end
    end
end)

hook.Add("AddTextField", "liaF1MenuAddTextField", function(sectionName, fieldName, labelText, valueFunc, icon)
    if IsValid(lia.gui.info) then
        local localizedSectionName = resolveCharInfoSectionName(sectionName)
        local localizedLabel = isstring(labelText) and L(labelText) or labelText
        local section = lia.gui.info.CharacterInformation[localizedSectionName]
        if section then
            for _, field in ipairs(section.fields) do
                if field.name == fieldName then return end
            end

            table.insert(section.fields, {
                type = "text",
                name = fieldName,
                label = localizedLabel,
                value = valueFunc or function() return "" end,
                icon = resolveIconMaterial(icon)
            })
        end
    end
end)

hook.Add("AddBarField", "liaF1MenuAddBarField", function(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc, icon)
    if IsValid(lia.gui.info) then
        local localizedSectionName = resolveCharInfoSectionName(sectionName)
        local localizedLabel = isstring(labelText) and L(labelText) or labelText
        local section = lia.gui.info.CharacterInformation[localizedSectionName]
        if section then
            for _, field in ipairs(section.fields) do
                if field.name == fieldName then return end
            end

            table.insert(section.fields, {
                type = "bar",
                name = fieldName,
                label = localizedLabel,
                min = minFunc or function() return 0 end,
                max = maxFunc or function() return 100 end,
                value = valueFunc or function() return 0 end,
                icon = resolveIconMaterial(icon)
            })
        end
    end
end)

hook.Add("PlayerBindPress", "liaF1MenuPlayerBindPress", function(client, bind, pressed)
    if bind:lower():find("gm_showhelp") and pressed then
        if IsValid(lia.gui.menu) then
            lia.gui.menu:remove()
        elseif client:getChar() then
            vgui.Create("liaMenu")
        end
        return true
    end
end)

hook.Add("CreateMenuButtons", "liaF1MenuCreateMenuButtons", function(tabs)
    tabs["@you"] = {
        name = "@you",
        icon = "icon16/user.png",
        func = function(statusPanel)
            statusPanel.info = vgui.Create("liaCharInfo", statusPanel)
            statusPanel.info:Dock(FILL)
            statusPanel.info:setup()
            statusPanel.info:SetAlpha(0)
            statusPanel.info:AlphaTo(255, 0.5)
        end
    }

    tabs["@information"] = {
        name = "@information",
        icon = "icon16/information.png",
        func = function(infoTabPanel)
            infoTabPanel:Clear()
            local frame = infoTabPanel:Add("DPanel")
            frame:Dock(FILL)
            frame.Paint = function() end
            local pages = {}
            hook.Run("CreateInformationButtons", pages)
            if not pages then return end
            for i = #pages, 1, -1 do
                if pages[i].shouldShow and not pages[i].shouldShow() then table.remove(pages, i) end
            end

            table.sort(pages, function(a, b)
                local an = tostring(localizeMenuLabel(a.name)):lower()
                local bn = tostring(localizeMenuLabel(b.name)):lower()
                return an < bn
            end)

            if #pages == 0 then return end
            local tabContainer = frame:Add("DPanel")
            tabContainer:Dock(TOP)
            tabContainer:SetTall(54)
            tabContainer:DockMargin(0, 0, 0, 12)
            tabContainer.Paint = function(_, w, h)
                local accent = getThemeColors()
                drawPanel(0, 0, w, h, 7, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 54))
            end

            local contentArea = frame:Add("DPanel")
            contentArea:Dock(FILL)
            contentArea.Paint = function() end
            local activeTab = 1
            local tabButtons = {}
            local tabPanels = {}
            for i, page in ipairs(pages) do
                local index = i
                local pageData = page
                local tabButton = tabContainer:Add("DButton")
                tabButton:SetText("")
                tabButton.Paint = function(s, w, h)
                    local accent, textColor = getThemeColors()
                    local active = activeTab == index
                    local hovered = s:IsHovered()
                    if active or hovered then
                        local background = active and Color(accent.r, accent.g, accent.b, 22) or Color(255, 255, 255, 6)
                        drawPanel(0, 0, w, h, 5, background, active and Color(accent.r, accent.g, accent.b, 70) or nil)
                    end

                    if active then
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                        surface.DrawRect(0, h - 3, w, 3)
                    end

                    local color = active and textColor or hovered and Color(215, 229, 229) or Color(165, 188, 189)
                    draw.SimpleText(string.upper(tostring(localizeMenuLabel(pageData.name))), "LiliaFont.18", w * 0.5, h * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                tabButton.DoClick = function()
                    if activeTab == index then return end
                    lia.websound.playButtonSound()
                    if IsValid(tabPanels[activeTab]) then tabPanels[activeTab]:SetVisible(false) end
                    activeTab = index
                    tabPanels[index]:SetVisible(true)
                    if pageData.drawFunc then pageData.drawFunc(tabPanels[index]) end
                end

                tabButtons[index] = tabButton
                local contentPanel = contentArea:Add("DPanel")
                contentPanel:Dock(FILL)
                contentPanel:SetVisible(index == 1)
                contentPanel.Paint = function() end
                tabPanels[index] = contentPanel
            end

            tabContainer.PerformLayout = function(_, w, h)
                local gap = 8
                local count = #tabButtons
                local available = w - gap * math.max(count - 1, 0)
                local width = count > 0 and math.floor(available / count) or available
                local x = 0
                for i, button in ipairs(tabButtons) do
                    local buttonWidth = i == count and w - x or width
                    button:SetPos(x, 0)
                    button:SetSize(buttonWidth, h)
                    x = x + buttonWidth + gap
                end
            end

            if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
        end
    }

    tabs["@settings"] = {
        name = "@settings",
        icon = "icon16/cog.png",
        func = function(settingsPanel)
            local frame = settingsPanel:Add("liaFrame")
            frame:Dock(FILL)
            frame:DockMargin(10, 10, 10, 10)
            frame:SetTitle(L("settings"))
            frame:LiteMode()
            frame:DisableCloseBtn()
            local pages = {}
            hook.Run("PopulateConfigurationButtons", pages)
            if not pages then return end
            for i = #pages, 1, -1 do
                if pages[i].shouldShow and not pages[i].shouldShow() then table.remove(pages, i) end
            end

            table.sort(pages, function(a, b)
                local an = tostring(localizeMenuLabel(a.name)):lower()
                local bn = tostring(localizeMenuLabel(b.name)):lower()
                return an < bn
            end)

            local tabContainer = vgui.Create("DPanel", frame)
            tabContainer:Dock(TOP)
            tabContainer:SetTall(40)
            tabContainer.Paint = function() end
            local contentArea = vgui.Create("liaScrollPanel", frame)
            contentArea:Dock(FILL)
            local activeTab = 1
            local tabButtons = {}
            local tabPanels = {}
            local baseTabWidths = {}
            local baseMargin = 8
            for i, page in ipairs(pages) do
                surface.SetFont("LiliaFont.18")
                local textWidth = surface.GetTextSize(localizeMenuLabel(page.name))
                local iconWidth = 0
                local padding = 20
                local minWidth = 80
                local btnWidth = math.max(minWidth, padding + iconWidth + textWidth + padding)
                baseTabWidths[i] = btnWidth
            end

            for i, page in ipairs(pages) do
                local tabButton = vgui.Create("liaTabButton", tabContainer)
                tabButton:Dock(LEFT)
                tabButton:DockMargin(i == 1 and 0 or baseMargin, 0, 0, 0)
                tabButton:SetTall(36)
                tabButton:SetText(localizeMenuLabel(page.name))
                tabButton:SetActive(i == 1)
                tabButton:SetWide(baseTabWidths[i] or 80)
                tabButton:SetDoClick(function()
                    if activeTab == i then return end
                    lia.websound.playButtonSound()
                    if tabPanels[activeTab] then tabPanels[activeTab]:SetVisible(false) end
                    activeTab = i
                    tabPanels[i]:SetVisible(true)
                    for j, btn in ipairs(tabButtons) do
                        if IsValid(btn) then btn:SetActive(j == i) end
                    end

                    if page.drawFunc then page.drawFunc(tabPanels[i]) end
                end)

                tabButtons[i] = tabButton
                local contentPanel = vgui.Create("DPanel", contentArea)
                contentPanel:Dock(TOP)
                contentPanel:SetVisible(i == 1)
                contentPanel.Paint = function() end
                contentPanel.PerformLayout = function(s) if IsValid(frame) and IsValid(tabContainer) then s:SetTall(frame:GetTall() - tabContainer:GetTall() - 20) end end
                tabPanels[i] = contentPanel
            end

            local function AdjustTabWidths()
                if not IsValid(tabContainer) then return end
                local totalTabsWidth = 0
                for _, width in pairs(baseTabWidths) do
                    totalTabsWidth = totalTabsWidth + width
                end

                local availableWidth = tabContainer:GetWide()
                local totalMargins = baseMargin * (#pages - 1)
                local extraSpace = availableWidth - totalTabsWidth - totalMargins
                if extraSpace > 0 then
                    local extraPerTab = math.floor(extraSpace / #pages)
                    local adjustedWidths = {}
                    for tabId, baseWidth in pairs(baseTabWidths) do
                        adjustedWidths[tabId] = baseWidth + extraPerTab
                    end

                    local remainder = extraSpace % #pages
                    if remainder > 0 then
                        for remainderId = 1, math.min(remainder, #pages) do
                            adjustedWidths[remainderId] = adjustedWidths[remainderId] + 1
                        end
                    end

                    for childId, child in ipairs(tabContainer:GetChildren()) do
                        if adjustedWidths[childId] and IsValid(child) then child:SetWide(adjustedWidths[childId]) end
                    end
                end
            end

            local originalPerformLayout = tabContainer.PerformLayout
            tabContainer.PerformLayout = function(s, w, h)
                if originalPerformLayout then originalPerformLayout(s, w, h) end
                timer.Simple(0, function() if IsValid(s) then AdjustTabWidths() end end)
            end

            if pages[1] and pages[1].drawFunc and IsValid(tabPanels[1]) then pages[1].drawFunc(tabPanels[1]) end
        end
    }

    local adminPages = {}
    hook.Run("PopulateAdminTabs", adminPages)
    for i = #adminPages, 1, -1 do
        if adminPages[i].shouldShow and not adminPages[i].shouldShow() then table.remove(adminPages, i) end
    end

    if not table.IsEmpty(adminPages) then
        tabs["@admin"] = {
            name = "@admin",
            icon = "icon16/shield.png",
            func = function(adminPanel)
                adminPanel:Clear()
                local frame = adminPanel:Add("EditablePanel")
                frame:Dock(FILL)
                frame.Paint = function() end
                local header = frame:Add("DPanel")
                header:Dock(TOP)
                header:SetTall(76)
                header.Paint = function()
                    local _, textColor = getThemeColors()
                    local pageName = adminPanel._activeAdminPageName or L("admin")
                    draw.SimpleText(pageName, "LiliaFont.30", 8, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Manage server administration tools and staff information.", "LiliaFont.17", 8, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local content = frame:Add("DPanel")
                content:Dock(FILL)
                content.Paint = function() end
                local details = content:Add("DPanel")
                details:Dock(FILL)
                details.Paint = function() end
                local pages = {}
                hook.Run("PopulateAdminTabs", pages)
                for i = #pages, 1, -1 do
                    if pages[i].shouldShow and not pages[i].shouldShow() then table.remove(pages, i) end
                end

                table.sort(pages, function(a, b)
                    local an = tostring(localizeMenuLabel(a.name)):lower()
                    local bn = tostring(localizeMenuLabel(b.name)):lower()
                    return an < bn
                end)

                table.insert(pages, 1, {
                    name = "onlineStaff",
                    icon = "icon16/user.png",
                    drawFunc = function(panel)
                        panel:Clear()
                        panel.originalStaffData = {}
                        panel.filteredStaffData = {}
                        panel.selectedStaffKey = nil
                        panel:DockPadding(0, 0, 0, 0)
                        panel.Paint = function() end
                        local function getStaffKey(staffInfo)
                            return tostring(staffInfo.steamID64 or staffInfo.steamID or staffInfo.name or staffInfo.characterName or "")
                        end

                        local function isStaffOnline(staffInfo)
                            if staffInfo.isOnline ~= nil then return staffInfo.isOnline == true end
                            if staffInfo.online ~= nil then return staffInfo.online == true end
                            local characterName = tostring(staffInfo.characterName or "")
                            return characterName ~= "" and characterName ~= tostring(L("unknown"))
                        end

                        local function getStaffDisplayName(staffInfo)
                            local steamName = tostring(staffInfo.name or L("unknown"))
                            local characterName = tostring(staffInfo.characterName or "")
                            if isStaffOnline(staffInfo) and characterName ~= "" and characterName ~= tostring(L("unknown")) then return characterName .. " - " .. steamName end
                            return steamName
                        end

                        local function filterStaffData(searchText)
                            searchText = string.Trim(tostring(searchText or "")):lower()
                            if searchText == "" then
                                panel.filteredStaffData = panel.originalStaffData
                                return panel.filteredStaffData
                            end

                            panel.filteredStaffData = {}
                            for _, staffInfo in ipairs(panel.originalStaffData) do
                                local name = tostring(staffInfo.name or ""):lower()
                                local usergroup = tostring(staffInfo.usergroup or ""):lower()
                                local characterName = tostring(staffInfo.characterName or ""):lower()
                                if name:find(searchText, 1, true) or usergroup:find(searchText, 1, true) or characterName:find(searchText, 1, true) then panel.filteredStaffData[#panel.filteredStaffData + 1] = staffInfo end
                            end
                            return panel.filteredStaffData
                        end

                        local staffContent = panel:Add("DPanel")
                        staffContent:Dock(FILL)
                        staffContent.Paint = function() end
                        local staffBrowser = staffContent:Add("DPanel")
                        staffBrowser:Dock(LEFT)
                        staffBrowser:DockMargin(0, 0, 14, 0)
                        staffBrowser:DockPadding(12, 12, 12, 12)
                        staffBrowser.Paint = function(_, w, h)
                            local accent = getThemeColors()
                            drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
                        end

                        local searchWrap = staffBrowser:Add("DPanel")
                        searchWrap:Dock(TOP)
                        searchWrap:SetTall(48)
                        searchWrap:DockMargin(0, 0, 0, 12)
                        searchWrap:DockPadding(40, 0, 8, 0)
                        searchWrap.Paint = function(_, w, h)
                            local accent = getThemeColors()
                            drawPanel(0, 0, w, h, 5, Color(5, 18, 23, 235), Color(accent.r, accent.g, accent.b, 92))
                            drawIcon(Material("icon16/magnifier.png", "smooth"), 14, math.floor(h * 0.5) - 8, 16, Color(155, 181, 182))
                        end

                        local searchEntry = searchWrap:Add("DTextEntry")
                        searchEntry:Dock(FILL)
                        searchEntry:SetFont("LiliaFont.17")
                        searchEntry:SetTextColor(Color(225, 236, 236))
                        searchEntry:SetCursorColor(getThemeColors())
                        searchEntry:SetPlaceholderText(L("searchStaff"))
                        searchEntry:SetDrawBackground(false)
                        searchEntry:SetPaintBackground(false)
                        searchEntry:SetPaintBorderEnabled(false)
                        local staffList = staffBrowser:Add("liaScrollPanel")
                        staffList:Dock(FILL)
                        staffList.Paint = function() end
                        local staffCanvas = staffList:GetCanvas()
                        if IsValid(staffCanvas) then
                            staffCanvas:DockPadding(0, 0, 4, 0)
                            staffCanvas.Paint = function() end
                        end

                        local staffDetails = staffContent:Add("DPanel")
                        staffDetails:Dock(FILL)
                        staffDetails:DockPadding(14, 14, 14, 14)
                        staffDetails.Paint = function(_, w, h)
                            local accent = getThemeColors()
                            drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
                        end

                        staffContent.PerformLayout = function(_, w) staffBrowser:SetWide(math.Clamp(math.floor(w * 0.34), 300, 390)) end
                        local function addStaffDetailSection(parent, title, rows)
                            local section = parent:Add("DPanel")
                            section:Dock(TOP)
                            section:SetTall(44 + #rows * 38)
                            section:DockMargin(0, 0, 0, 12)
                            section:DockPadding(14, 42, 14, 8)
                            section.Paint = function(_, w, h)
                                local accent = getThemeColors()
                                drawPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
                                draw.SimpleText(title, "LiliaFont.17", 14, 12, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
                                surface.DrawRect(12, 36, w - 24, 1)
                            end

                            for _, rowData in ipairs(rows) do
                                local row = section:Add("DPanel")
                                row:Dock(TOP)
                                row:SetTall(38)
                                row.Paint = function(_, w, h)
                                    draw.SimpleText(rowData[1], "LiliaFont.17", 0, h * 0.5, Color(185, 204, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                    draw.SimpleText(rowData[2], "LiliaFont.17", w, h * 0.5, Color(225, 236, 236), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                                    surface.SetDrawColor(255, 255, 255, 16)
                                    surface.DrawRect(0, h - 1, w, 1)
                                end
                            end
                        end

                        local function buildStaffDetails(staffInfo)
                            staffDetails:Clear()
                            if not staffInfo then
                                local empty = staffDetails:Add("DLabel")
                                empty:Dock(FILL)
                                empty:SetText(L("noStaffCurrentlyOnline"))
                                empty:SetTextColor(Color(150, 170, 170))
                                empty:SetFont("LiliaFont.20")
                                empty:SetContentAlignment(5)
                                return
                            end

                            panel.selectedStaffKey = getStaffKey(staffInfo)
                            local accent, textColor = getThemeColors()
                            local steamName = tostring(staffInfo.name or L("unknown"))
                            local displayName = getStaffDisplayName(staffInfo)
                            local characterName = tostring(staffInfo.characterName or L("unknown"))
                            local usergroup = tostring(staffInfo.usergroup or L("none"))
                            local isOnDuty = staffInfo.isStaffOnDuty == true
                            local dutyText = isOnDuty and "ON DUTY" or "OFF DUTY"
                            local staffHeader = staffDetails:Add("DPanel")
                            staffHeader:Dock(TOP)
                            staffHeader:SetTall(116)
                            staffHeader:DockMargin(0, 0, 0, 12)
                            staffHeader.Paint = function(_, w, h)
                                drawPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
                                surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                                surface.DrawRect(0, 0, 3, h)
                                drawIcon(Material("icon16/user.png", "smooth"), 26, math.floor(h * 0.5) - 28, 56, color_white)
                                local textX = 104
                                draw.SimpleText(displayName, "LiliaFont.25", textX, 24, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                draw.SimpleText(characterName .. "  •  " .. usergroup, "LiliaFont.17", textX, 73, Color(185, 204, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                local badgeW = 120
                                local badgeH = 34
                                local badgeX = w - badgeW - 22
                                local badgeY = math.floor((h - badgeH) * 0.5)
                                local badgeFill = isOnDuty and Color(accent.r, accent.g, accent.b, 20) or Color(255, 255, 255, 7)
                                local badgeOutline = isOnDuty and Color(accent.r, accent.g, accent.b, 95) or Color(255, 255, 255, 28)
                                local badgeColor = isOnDuty and accent or Color(145, 163, 164)
                                drawPanel(badgeX, badgeY, badgeW, badgeH, 5, badgeFill, badgeOutline)
                                draw.RoundedBox(4, badgeX + 14, badgeY + 13, 8, 8, badgeColor)
                                draw.SimpleText(dutyText, "LiliaFont.15", badgeX + 31, badgeY + badgeH * 0.5, badgeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            end

                            local detailScroll = staffDetails:Add("liaScrollPanel")
                            detailScroll:Dock(FILL)
                            detailScroll.Paint = function() end
                            local detailCanvas = detailScroll:GetCanvas()
                            if IsValid(detailCanvas) then
                                detailCanvas:DockPadding(0, 0, 4, 0)
                                detailCanvas.Paint = function() end
                            else
                                detailCanvas = detailScroll
                            end

                            local generalRows = {{"Steam Name", steamName}, {"Usergroup", usergroup}}
                            if isStaffOnline(staffInfo) and characterName ~= tostring(L("unknown")) then table.insert(generalRows, 2, {"Character", characterName}) end
                            addStaffDetailSection(detailCanvas, "GENERAL", generalRows)
                            addStaffDetailSection(detailCanvas, "STATUS", {{"Connection", isStaffOnline(staffInfo) and "Online" or "Offline"}, {"Staff Duty", isOnDuty and L("yes") or L("no")}})
                            if IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("viewStaffManagement") then
                                addStaffDetailSection(detailCanvas, "MODERATION", {{"Warnings Issued", tostring(staffInfo.warnings or 0)}, {"Tickets Claimed", tostring(staffInfo.tickets or 0)}})
                                addStaffDetailSection(detailCanvas, "ACTIONS", {{"Kicks", tostring(staffInfo.kicks or 0)}, {"Kills", tostring(staffInfo.kills or 0)}, {"Respawns", tostring(staffInfo.respawns or 0)}, {"Blinds", tostring(staffInfo.blinds or 0)}, {"Mutes", tostring(staffInfo.mutes or 0)}, {"Jails", tostring(staffInfo.jails or 0)}, {"Strips", tostring(staffInfo.strips or 0)}})
                            end
                        end

                        local function rebuildStaffList(dataToShow)
                            if not IsValid(staffCanvas) then return end
                            staffCanvas:Clear()
                            local data = dataToShow or {}
                            local firstStaff
                            local selectedStaff
                            for _, staffInfo in ipairs(data) do
                                local currentStaff = staffInfo
                                local displayName = getStaffDisplayName(currentStaff)
                                local usergroup = tostring(currentStaff.usergroup or L("none"))
                                local isOnDuty = currentStaff.isStaffOnDuty == true
                                local currentKey = getStaffKey(currentStaff)
                                local button = staffCanvas:Add("DButton")
                                button:Dock(TOP)
                                button:SetTall(64)
                                button:DockMargin(0, 0, 0, 8)
                                button:SetText("")
                                button.Paint = function(s, w, h)
                                    local currentAccent = getThemeColors()
                                    local active = panel.selectedStaffKey == currentKey
                                    local hovered = s:IsHovered()
                                    local bg = active and Color(currentAccent.r, currentAccent.g, currentAccent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(2, 14, 18, 130)
                                    drawPanel(0, 0, w, h, 5, bg, active and Color(currentAccent.r, currentAccent.g, currentAccent.b, 145) or Color(currentAccent.r, currentAccent.g, currentAccent.b, 42))
                                    if active then
                                        surface.SetDrawColor(currentAccent.r, currentAccent.g, currentAccent.b, 245)
                                        surface.DrawRect(0, 7, 3, h - 14)
                                    end

                                    drawIcon(Material("icon16/user.png", "smooth"), 14, 18, 28, active and color_white or Color(175, 196, 196))
                                    draw.SimpleText(displayName, "LiliaFont.18", 54, 12, active and color_white or Color(220, 232, 232), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                    draw.SimpleText(usergroup, "LiliaFont.15", 54, 38, Color(185, 204, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                    local statusColor = isOnDuty and currentAccent or Color(135, 156, 157)
                                    draw.SimpleText(isOnDuty and "ON DUTY" or usergroup, "LiliaFont.15", w - 12, h * 0.5, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                                end

                                button.DoClick = function()
                                    lia.websound.playButtonSound()
                                    panel.selectedStaffKey = currentKey
                                    buildStaffDetails(currentStaff)
                                end

                                if not firstStaff then firstStaff = currentStaff end
                                if panel.selectedStaffKey == currentKey then selectedStaff = currentStaff end
                            end

                            if #data == 0 then
                                local empty = staffCanvas:Add("DLabel")
                                empty:Dock(TOP)
                                empty:SetTall(64)
                                empty:SetText(L("noStaffCurrentlyOnline"))
                                empty:SetTextColor(Color(145, 165, 166))
                                empty:SetFont("LiliaFont.17")
                                empty:SetContentAlignment(5)
                                buildStaffDetails(nil)
                                return
                            end

                            buildStaffDetails(selectedStaff or firstStaff)
                        end

                        panel.updateStaffList = rebuildStaffList
                        searchEntry.OnChange = function(s) rebuildStaffList(filterStaffData(s:GetValue())) end
                        local function onStaffDataReceived(staffData)
                            if not IsValid(panel) then return end
                            panel.originalStaffData = staffData or {}
                            panel.filteredStaffData = filterStaffData(IsValid(searchEntry) and searchEntry:GetValue() or "")
                            rebuildStaffList(panel.filteredStaffData)
                        end

                        hook.Remove("OnlineStaffDataReceived", "liaF1MenuStaffData")
                        hook.Add("OnlineStaffDataReceived", "liaF1MenuStaffData", onStaffDataReceived)
                        net.Start("liaRequestOnlineStaffData")
                        net.SendToServer()
                        timer.Create("liaAdminStaffTableRefresh", 30, 0, function()
                            if IsValid(panel) then
                                net.Start("liaRequestOnlineStaffData")
                                net.SendToServer()
                            else
                                timer.Remove("liaAdminStaffTableRefresh")
                            end
                        end)

                        rebuildStaffList(panel.filteredStaffData)
                        panel.OnRemove = function()
                            hook.Remove("OnlineStaffDataReceived", "liaF1MenuStaffData")
                            if timer.Exists("liaAdminStaffTableRefresh") then timer.Remove("liaAdminStaffTableRefresh") end
                        end
                    end
                })

                local menuAdminPageIndex = IsValid(lia.gui.menu) and lia.gui.menu.activeAdminPageIndex or nil
                local activePageIndex = math.Clamp(tonumber(adminPanel.pendingAdminPageIndex or adminPanel.activeAdminPageIndex or menuAdminPageIndex) or 1, 1, math.max(#pages, 1))
                local function openAdminPage(index)
                    index = math.Clamp(tonumber(index) or 1, 1, math.max(#pages, 1))
                    local page = pages[index]
                    if not page then return end
                    activePageIndex = index
                    adminPanel._activeAdminPageName = tostring(localizeMenuLabel(page.name))
                    adminPanel.activeAdminPageIndex = index
                    adminPanel.pendingAdminPageIndex = nil
                    if IsValid(lia.gui.menu) then
                        lia.gui.menu.activeAdminPageIndex = index
                        lia.gui.menu.pendingAdminPageIndex = nil
                        lia.gui.menu:UpdateTabColors()
                    end

                    details:Clear()
                    local pageHost = details:Add("DPanel")
                    pageHost:Dock(FILL)
                    pageHost.Paint = function() end
                    if page.drawFunc then page.drawFunc(pageHost) end
                end

                adminPanel._openAdminPage = openAdminPage
                adminPanel._adminPages = pages
                timer.Simple(0, function()
                    if not IsValid(frame) then return end
                    local requestedIndex = IsValid(lia.gui.menu) and lia.gui.menu.pendingAdminPageIndex or nil
                    openAdminPage(requestedIndex or activePageIndex)
                end)
            end
        }
    end

    local hasThemesPrivilege = IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("accessEditConfigurationMenu") or false
    if hasThemesPrivilege then
        tabs["@themes"] = {
            name = "@themes",
            icon = "icon16/color_wheel.png",
            func = function(themesPanel)
                themesPanel:Clear()
                local function getLocalizedThemeName(themeID)
                    local properCaseName = themeID:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
                    local localizationKey = "theme" .. properCaseName:gsub(" ", ""):gsub("-", "")
                    return L(localizationKey) or themeID
                end

                local function prettify(name)
                    name = tostring(name or ""):gsub("_", " ")
                    name = name:gsub("([a-z])([A-Z])", "%1 %2")
                    return name:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
                end

                local descriptionMap = {
                    accent = "Primary accent color used for highlights and important elements.",
                    background = "Main background color of the interface.",
                    backgroundalpha = "Transparency level for background elements.",
                    backgroundpanelpopup = "Background color for panels and popups.",
                    button = "Default button background color.",
                    buttonhovered = "Button background color when hovered.",
                    buttonshadow = "Shadow color for buttons and raised elements.",
                    category = "Color for category elements and tabs.",
                    categoryopened = "Color for opened or active categories.",
                    border = "Default border and outline color.",
                    text = "Primary interface text color.",
                    textsecondary = "Secondary text color for supporting information.",
                    textmuted = "Muted text color for subtle labels.",
                    textinverse = "Inverse text color for bright surfaces.",
                    success = "Color used for positive confirmation states.",
                    warning = "Color used for warning states and notices.",
                    danger = "Color used for destructive or critical actions.",
                    info = "Color used for informational highlights."
                }

                local function getEntryDescription(name)
                    local normalized = tostring(name or ""):lower():gsub("[^%w]", "")
                    return descriptionMap[normalized] or "Theme color token used by the interface."
                end

                local function getPreviewColors(themeData)
                    local colors = {}
                    for _, value in pairs(themeData or {}) do
                        if lia.color.isColor(value) then
                            colors[#colors + 1] = value
                        elseif istable(value) then
                            for _, subValue in ipairs(value) do
                                if lia.color.isColor(subValue) then
                                    colors[#colors + 1] = subValue
                                    if #colors >= 4 then break end
                                end
                            end
                        end

                        if #colors >= 4 then break end
                    end
                    return colors
                end

                local function collectEntries(themeData)
                    local entries = {}
                    for key, value in pairs(themeData or {}) do
                        if lia.color.isColor(value) then
                            entries[#entries + 1] = {
                                name = key,
                                colors = {value}
                            }
                        elseif istable(value) then
                            local colors = {}
                            for _, subValue in ipairs(value) do
                                if lia.color.isColor(subValue) then colors[#colors + 1] = subValue end
                            end

                            if #colors > 0 then
                                entries[#entries + 1] = {
                                    name = key,
                                    colors = colors
                                }
                            end
                        end
                    end

                    table.sort(entries, function(a, b) return tostring(a.name) < tostring(b.name) end)
                    return entries
                end

                local function colorToHex(col)
                    if not lia.color.isColor(col) then return "-" end
                    return string.format("#%02X%02X%02X", col.r or 0, col.g or 0, col.b or 0)
                end

                local function styleThemeButton(button, primary)
                    button:SetFont("LiliaFont.18")
                    button.Paint = function(self, w, h)
                        local accent, textColor = getThemeColors()
                        local hovered = self:IsHovered()
                        if primary then
                            local background = hovered and Color(accent.r, accent.g, accent.b, 235) or Color(accent.r, accent.g, accent.b, 205)
                            drawPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, 255))
                            self:SetTextColor(color_white)
                        else
                            local background = hovered and Color(accent.r, accent.g, accent.b, 24) or Color(3, 16, 21, 185)
                            drawPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, 68))
                            self:SetTextColor(textColor)
                        end
                    end
                end

                local themeIDs = lia.color.getAllThemes()
                table.sort(themeIDs, function(a, b) return getLocalizedThemeName(a) < getLocalizedThemeName(b) end)
                local currentTheme = lia.color.getCurrentTheme()
                local selectedTheme = currentTheme or themeIDs[1]
                local root = themesPanel:Add("EditablePanel")
                root:Dock(FILL)
                root.Paint = function() end
                local header = root:Add("EditablePanel")
                header:Dock(TOP)
                header:SetTall(76)
                header.Paint = function()
                    local _, textColor = getThemeColors()
                    draw.SimpleText("Themes", "LiliaFont.30", 8, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Choose and apply an interface color preset.", "LiliaFont.17", 8, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local body = root:Add("EditablePanel")
                body:Dock(FILL)
                body.Paint = nil
                local presetPanel = body:Add("EditablePanel")
                presetPanel:Dock(LEFT)
                presetPanel:SetWide(300)
                presetPanel:DockMargin(0, 0, 16, 0)
                presetPanel.Paint = function(_, w, h)
                    local accent, textColor = getThemeColors()
                    drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
                    draw.SimpleText("Presets", "LiliaFont.25", 16, 14, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                presetPanel:DockPadding(16, 54, 16, 16)
                local currentCard = presetPanel:Add("EditablePanel")
                currentCard:Dock(BOTTOM)
                currentCard:SetTall(96)
                currentCard.Paint = function(_, w, h)
                    local accent, textColor = getThemeColors()
                    drawPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
                    draw.SimpleText("Active Theme", "LiliaFont.17", 18, 14, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText(getLocalizedThemeName(currentTheme or ""), "LiliaFont.24", 18, 39, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Currently applied to the interface.", "LiliaFont.16", 18, 68, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local presetScroll = presetPanel:Add("liaScrollPanel")
                presetScroll:Dock(FILL)
                presetScroll:DockMargin(0, 0, 0, 12)
                local contentPanel = body:Add("EditablePanel")
                contentPanel:Dock(FILL)
                contentPanel.Paint = function(_, w, h)
                    local accent = getThemeColors()
                    drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
                end

                contentPanel:DockPadding(16, 16, 16, 16)
                local contentHeader = contentPanel:Add("EditablePanel")
                contentHeader:Dock(TOP)
                contentHeader:SetTall(54)
                contentHeader.Paint = function(_, w, h)
                    local accent, textColor = getThemeColors()
                    draw.SimpleText("Color Settings", "LiliaFont.25", 0, 0, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Read-only color values for the selected preset.", "LiliaFont.16", 0, 30, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
                    surface.DrawLine(0, h - 1, w, h - 1)
                end

                local columnHeader = contentPanel:Add("EditablePanel")
                columnHeader:Dock(TOP)
                columnHeader:SetTall(30)
                columnHeader:DockMargin(0, 8, 0, 8)
                columnHeader.Paint = function(_, w, h)
                    draw.SimpleText("Name", "LiliaFont.15", 20, 0, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Description", "LiliaFont.15", math.floor(w * 0.42), 0, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Hex", "LiliaFont.15", w - 198, 0, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Preview", "LiliaFont.15", w - 88, 0, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local footer = contentPanel:Add("EditablePanel")
                footer:Dock(BOTTOM)
                footer:SetTall(82)
                footer:DockMargin(0, 14, 0, 0)
                footer.Paint = function(_, w, h)
                    local accent = getThemeColors()
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
                    surface.DrawLine(0, 0, w, 0)
                end

                local applyButton = footer:Add("DButton")
                applyButton:Dock(RIGHT)
                applyButton:SetWide(280)
                applyButton:DockMargin(16, 18, 0, 0)
                applyButton:SetText("APPLY THEME")
                styleThemeButton(applyButton, true)
                local contentScroll = contentPanel:Add("liaScrollPanel")
                contentScroll:Dock(FILL)
                local function updateActionButtons()
                    local isCurrent = selectedTheme == currentTheme
                    applyButton:SetEnabled(not isCurrent)
                    applyButton:SetText(isCurrent and "CURRENTLY SELECTED" or "APPLY THEME")
                end

                local function rebuildEntries()
                    if not IsValid(contentScroll) then return end
                    contentScroll:Clear()
                    local themeData = lia.color.themes[selectedTheme] or {}
                    for _, entry in ipairs(collectEntries(themeData)) do
                        local row = contentScroll:Add("EditablePanel")
                        row:Dock(TOP)
                        row:DockMargin(0, 0, 0, 8)
                        row:SetTall(68)
                        row.Paint = function(_, w, h)
                            local accent, textColor = getThemeColors()
                            drawPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
                            draw.SimpleText(prettify(entry.name), "LiliaFont.18", 20, 15, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(getEntryDescription(entry.name), "LiliaFont.16", math.floor(w * 0.42), 17, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            local hexValue = colorToHex(entry.colors[1])
                            drawPanel(w - 208, 12, 92, h - 24, 6, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 45))
                            draw.SimpleText(hexValue, "LiliaFont.16", w - 162, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                            local swatchX = w - 84
                            local swatchSize = 44
                            local swatchY = math.floor((h - swatchSize) * 0.5)
                            for index, col in ipairs(entry.colors) do
                                local x = swatchX + (index - 1) * 16
                                if index == 1 then
                                    draw.RoundedBox(6, x, swatchY, swatchSize, swatchSize, col)
                                    surface.SetDrawColor(255, 255, 255, 225)
                                    surface.DrawOutlinedRect(x, swatchY, swatchSize, swatchSize, 1)
                                else
                                    local dotX = w - 98 - (index - 2) * 12
                                    draw.RoundedBox(3, dotX, h - 18, 8, 8, col)
                                end
                            end
                        end
                    end
                end

                local presetButtons = {}
                local function rebuildPresetButtons()
                    if not IsValid(presetScroll) then return end
                    presetScroll:Clear()
                    presetButtons = {}
                    for _, themeID in ipairs(themeIDs) do
                        local themeData = lia.color.themes[themeID]
                        if istable(themeData) then
                            local displayName = getLocalizedThemeName(themeID)
                            local button = presetScroll:Add("DButton")
                            button:Dock(TOP)
                            button:DockMargin(0, 0, 0, 8)
                            button:SetTall(52)
                            button:SetText("")
                            local previewColors = getPreviewColors(themeData)
                            button.Paint = function(self, w, h)
                                local accent = select(1, getThemeColors())
                                local isSelected = selectedTheme == themeID
                                local background = isSelected and Color(accent.r, accent.g, accent.b, 26) or self:IsHovered() and Color(255, 255, 255, 7) or Color(3, 16, 21, 185)
                                local outline = isSelected and Color(accent.r, accent.g, accent.b, 145) or Color(accent.r, accent.g, accent.b, 68)
                                drawPanel(0, 0, w, h, 6, background, outline)
                                if isSelected then
                                    draw.SimpleText("✓", "LiliaFont.24", 24, h * 0.5, Color(accent.r, accent.g, accent.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                else
                                    surface.SetDrawColor(98, 126, 130, 180)
                                    surface.DrawOutlinedRect(16, h * 0.5 - 8, 16, 16, 1)
                                end

                                local _, textColor = getThemeColors()
                                draw.SimpleText(displayName, "LiliaFont.20", 48, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                local startX = w - 112
                                for index, col in ipairs(previewColors) do
                                    draw.RoundedBox(6, startX + (index - 1) * 22, h * 0.5 - 8, 16, 16, col)
                                    surface.SetDrawColor(255, 255, 255, 18)
                                    surface.DrawOutlinedRect(startX + (index - 1) * 22, h * 0.5 - 8, 16, 16, 1)
                                end
                            end

                            button.DoClick = function()
                                selectedTheme = themeID
                                rebuildPresetButtons()
                                rebuildEntries()
                                updateActionButtons()
                            end

                            presetButtons[#presetButtons + 1] = button
                        end
                    end
                end

                applyButton.DoClick = function()
                    if not selectedTheme or selectedTheme == currentTheme then return end
                    lia.websound.playButtonSound()
                    net.Start("liaCfgSet")
                    net.WriteString("Theme")
                    net.WriteString(L("theme"))
                    net.WriteType(selectedTheme)
                    net.SendToServer()
                    currentTheme = selectedTheme
                    rebuildPresetButtons()
                    rebuildEntries()
                    updateActionButtons()
                end

                rebuildPresetButtons()
                rebuildEntries()
                updateActionButtons()
            end
        }
    end
end)

hook.Add("CanDisplayCharInfo", "liaF1MenuCanDisplayCharInfo", function(name)
    local client = LocalPlayer()
    if not client then return true end
    local character = client:getChar()
    if not character then return true end
    if not lia.class or not lia.class.list then return true end
    local class = lia.class.list[character:getClass()]
    if name == "class" and not class then return false end
    return true
end)
