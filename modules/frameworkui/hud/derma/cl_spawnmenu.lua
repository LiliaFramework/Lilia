local PANEL = {}
DEFINE_BASECLASS("DScrollPanel")
AccessorFunc(PANEL, "m_pControllerPanel", "ControllerPanel")
AccessorFunc(PANEL, "m_strCategoryName", "CategoryName")
AccessorFunc(PANEL, "m_bTriggerSpawnlistChange", "TriggerSpawnlistChange")
function PANEL:Init()
    self:SetPaintBackground(false)
    self.IconList = vgui.Create("DTileLayout", self:GetCanvas())
    self.IconList:SetBaseSize(64)
    self.IconList:MakeDroppable("SandboxContentPanel", true)
    self.IconList:SetSelectionCanvas(true)
    self.IconList:Dock(TOP)
    self.IconList.OnModified = function() self:OnModified() end
    self.IconList.OnMousePressed = function(s, btn)
        s:EndBoxSelection()
        if btn ~= MOUSE_RIGHT then DPanel.OnMousePressed(s, btn) end
    end

    self.IconList.OnMouseReleased = function(s, btn)
        DPanel.OnMouseReleased(s, btn)
        if btn ~= MOUSE_RIGHT or s:GetReadOnly() then return end
        local menu = DermaMenu()
        menu:AddOption("#spawnmenu.newlabel", function()
            local label = vgui.Create("ContentHeader")
            self:Add(label)
            local x, y = self.IconList:ScreenToLocal(input.GetCursorPos())
            label:MoveToAfter(self.IconList:GetClosestChild(self:GetCanvas():GetWide(), y))
            self:OnModified()
        end):SetIcon("icon16/text_heading_1.png")

        menu:Open()
    end

    self.IconList.ContentContainer = self
end

function PANEL:Add(pnl)
    self.IconList:Add(pnl)
    if pnl.InstallMenu then pnl:InstallMenu(self) end
    self:Layout()
end

function PANEL:Layout()
    self.IconList:Layout()
    self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
    BaseClass.PerformLayout(self, w, h)
    self.IconList:SetMinHeight(self:GetTall() - 16)
end

function PANEL:RebuildAll(proppanel)
    for k, v in ipairs(self.IconList:GetChildren()) do
        v:RebuildSpawnIcon()
    end
end

function PANEL:GetCount()
    return #self.IconList:GetChildren()
end

function PANEL:Clear()
    self.IconList:Clear()
end

function PANEL:SetTriggerSpawnlistChange(bTrigger)
    self.m_bTriggerSpawnlistChange = bTrigger
    self.IconList:SetReadOnly(not bTrigger)
end

function PANEL:OnModified()
    if not self:GetTriggerSpawnlistChange() then return end
    hook.Run("SpawnlistContentChanged")
end

function PANEL:ContentsToTable(contentpanel)
    local tab = {}
    for k, v in ipairs(self.IconList:GetChildren()) do
        v:ToTable(tab)
    end
    return tab
end

function PANEL:Copy()
    local copy = vgui.Create("ContentContainer", self:GetParent())
    copy:CopyBase(self)
    copy.IconList:CopyContents(self.IconList)
    return copy
end

vgui.Register("ContentContainer", PANEL, "DScrollPanel")
hook.Add("SpawnlistOpenGenericMenu", "DragAndDropSelectionMenu", function(canvas)
    if canvas:GetReadOnly() then return end
    local selected = canvas:GetSelectedChildren()
    local menu = DermaMenu()
    local spawnicons = 0
    local icon = nil
    for id, pnl in pairs(selected) do
        if pnl.InternalAddResizeMenu then
            spawnicons = spawnicons + 1
            icon = pnl
        end
    end

    if spawnicons > 0 then
        icon:InternalAddResizeMenu(menu, function(w, h)
            for id, pnl in pairs(selected) do
                if not pnl.InternalAddResizeMenu then continue end
                pnl:SetSize(w, h)
                pnl:InvalidateLayout(true)
                pnl:GetParent():OnModified()
                pnl:GetParent():Layout()
                pnl:SetModel(pnl:GetModelName(), pnl:GetSkinID(), pnl:GetBodyGroup())
            end
        end, language.GetPhrase("spawnmenu.menu.resizex"):format(spawnicons))

        menu:AddOption(language.GetPhrase("spawnmenu.menu.rerenderx"):format(spawnicons), function()
            for id, pnl in pairs(selected) do
                if not pnl.RebuildSpawnIcon then continue end
                pnl:RebuildSpawnIcon()
            end
        end):SetIcon("icon16/picture.png")
    end

    menu:AddSpacer()
    menu:AddOption(language.GetPhrase("spawnmenu.menu.deletex"):format(#selected), function()
        for k, v in pairs(selected) do
            v:Remove()
        end

        hook.Run("SpawnlistContentChanged")
    end):SetIcon("icon16/bin_closed.png")

    menu:Open()
end)

surface.CreateFont("ContentHeader", {
    font = "Helvetica",
    size = 50,
    weight = 1000
})

local PANEL = {}
function PANEL:Init()
    self:SetFont("ContentHeader")
    self:SetBright(true)
    self:SetExpensiveShadow(2, Color(0, 0, 0, 130))
    self:SetSize(64, 64)
    self.OwnLine = true
    self:SetAutoStretch(true)
end

function PANEL:PerformLayout()
    self:SizeToContents()
end

function PANEL:SizeToContents()
    local w = self:GetContentSize()
    if IsValid(self:GetParent()) then w = math.min(w, self:GetParent():GetWide() - 32) end
    self:SetSize(math.max(w, 64) + 16, 64)
end

function PANEL:ToTable(bigtable)
    local tab = {}
    tab.type = "header"
    tab.text = self:GetText()
    table.insert(bigtable, tab)
end

function PANEL:Copy()
    local copy = vgui.Create("ContentHeader", self:GetParent())
    copy:SetText(self:GetText())
    copy:CopyBounds(self)
    return copy
end

function PANEL:PaintOver(w, h)
    self:DrawSelections()
end

function PANEL:OnLabelTextChanged(txt)
    hook.Run("SpawnlistContentChanged")
    return txt
end

function PANEL:IsEnabled()
    return not IsValid(self:GetParent()) or not self:GetParent().GetReadOnly or not self:GetParent():GetReadOnly()
end

function PANEL:DoRightClick()
    local pCanvas = self:GetSelectionCanvas()
    if IsValid(pCanvas) and pCanvas:NumSelectedChildren() > 0 and self:IsSelected() then return hook.Run("SpawnlistOpenGenericMenu", pCanvas) end
    self:OpenMenu()
end

function PANEL:UpdateColours(skin)
    if self:GetHighlight() then return self:SetTextStyleColor(skin.Colours.Label.Highlight) end
    if self:GetBright() then return self:SetTextStyleColor(skin.Colours.Label.Bright) end
    if self:GetDark() then return self:SetTextStyleColor(skin.Colours.Label.Dark) end
    return self:SetTextStyleColor(skin.Colours.Label.Default)
end

function PANEL:OpenMenu()
    if IsValid(self:GetParent()) and self:GetParent().GetReadOnly and self:GetParent():GetReadOnly() then return end
    local menu = DermaMenu()
    menu:AddOption("#spawnmenu.menu.delete", function()
        self:Remove()
        hook.Run("SpawnlistContentChanged")
    end):SetIcon("icon16/bin_closed.png")

    menu:Open()
end

vgui.Register("ContentHeader", PANEL, "DLabelEditable")
local PANEL = {}
local matOverlay_Normal = Material("gui/ContentIcon-normal.png")
local matOverlay_Hovered = Material("gui/ContentIcon-hovered.png")
local matOverlay_AdminOnly = Material("icon16/shield.png")
local matOverlay_NPCWeapon = Material("icon16/monkey.png")
local matOverlay_NPCWeaponSelected = Material("icon16/monkey_tick.png")
AccessorFunc(PANEL, "m_Color", "Color")
AccessorFunc(PANEL, "m_Type", "ContentType")
AccessorFunc(PANEL, "m_SpawnName", "SpawnName")
AccessorFunc(PANEL, "m_NPCWeapon", "NPCWeapon")
AccessorFunc(PANEL, "m_bAdminOnly", "AdminOnly")
AccessorFunc(PANEL, "m_bIsNPCWeapon", "IsNPCWeapon")
function PANEL:OpenGenericSpawnmenuRightClickMenu()
    local menu = DermaMenu()
    if self:GetSpawnName() and self:GetSpawnName() ~= "" then menu:AddOption("#spawnmenu.menu.copy", function() SetClipboardText(self:GetSpawnName()) end):SetIcon("icon16/page_copy.png") end
    if isfunction(self.OpenMenuExtra) then self:OpenMenuExtra(menu) end
    hook.Run("SpawnmenuIconMenuOpen", menu, self, self:GetContentType())
    if not IsValid(self:GetParent()) or not self:GetParent().GetReadOnly or not self:GetParent():GetReadOnly() then
        menu:AddSpacer()
        menu:AddOption("#spawnmenu.menu.delete", function()
            self:Remove()
            hook.Run("SpawnlistContentChanged")
        end):SetIcon("icon16/bin_closed.png")
    end

    menu:Open()
end

function PANEL:Init()
    self:SetPaintBackground(false)
    self:SetSize(128, 128)
    self:SetText("")
    self:SetDoubleClickingEnabled(false)
    self.Image = self:Add("DImage")
    self.Image:SetPos(3, 3)
    self.Image:SetSize(122, 122)
    self.Image:SetVisible(false)
    self.Border = 0
end

function PANEL:SetName(name)
    self:SetTooltip(name)
    self.m_NiceName = name
end

function PANEL:SetMaterial(name)
    self.m_MaterialName = name
    local mat = Material(name)
    if not mat or mat:IsError() then
        name = name:Replace("entities/", "VGUI/entities/")
        name = name:Replace(".png", "")
        mat = Material(name)
    end

    if not mat or mat:IsError() then return end
    self.Image:SetMaterial(mat)
end

function PANEL:DoRightClick()
    local pCanvas = self:GetSelectionCanvas()
    if IsValid(pCanvas) and pCanvas:NumSelectedChildren() > 0 and self:IsSelected() then return hook.Run("SpawnlistOpenGenericMenu", pCanvas) end
    self:OpenMenu()
end

function PANEL:DoClick()
end

function PANEL:OpenMenu()
end

function PANEL:OnDepressionChanged(b)
end

local shadowColor = Color(0, 0, 0, 200)
local function DrawTextShadow(text, x, y)
    draw.SimpleText(text, "DermaDefault", x + 1, y + 1, shadowColor)
    draw.SimpleText(text, "DermaDefault", x, y, color_white)
end

function PANEL:Paint(w, h)
    if self.Depressed and not self.Dragging then
        if self.Border ~= 8 then
            self.Border = 8
            self:OnDepressionChanged(true)
        end
    else
        if self.Border ~= 0 then
            self.Border = 0
            self:OnDepressionChanged(false)
        end
    end

    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    self.Image:PaintAt(3 + self.Border, 3 + self.Border, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2)
    render.PopFilterMin()
    render.PopFilterMag()
    surface.SetDrawColor(255, 255, 255, 255)
    local drawText = false
    if not dragndrop.IsDragging() and (self:IsHovered() or self.Depressed or self:IsChildHovered()) then
        surface.SetMaterial(matOverlay_Hovered)
    else
        surface.SetMaterial(matOverlay_Normal)
        drawText = true
    end

    surface.DrawTexturedRect(self.Border, self.Border, w - self.Border * 2, h - self.Border * 2)
    if self:GetAdminOnly() then
        surface.SetMaterial(matOverlay_AdminOnly)
        surface.DrawTexturedRect(self.Border + 8, self.Border + 8, 16, 16)
    end

    if self:GetIsNPCWeapon() then
        surface.SetMaterial(matOverlay_NPCWeapon)
        if self:GetSpawnName() == GetConVarString("gmod_npcweapon") then surface.SetMaterial(matOverlay_NPCWeaponSelected) end
        surface.DrawTexturedRect(w - self.Border - 24, self.Border + 8, 16, 16)
    end

    self:ScanForNPCWeapons()
    if drawText then
        local buffere = self.Border + 10
        local px, py = self:LocalToScreen(buffere, 0)
        local pw, ph = self:LocalToScreen(w - buffere, h)
        render.SetScissorRect(px, py, pw, ph, true)
        surface.SetFont("DermaDefault")
        local tW, tH = surface.GetTextSize(self.m_NiceName)
        local x = w / 2 - tW / 2
        if tW > w - buffere * 2 then
            local mx, my = self:ScreenToLocal(input.GetCursorPos())
            local diff = tW - w + buffere * 2
            x = buffere + math.Remap(math.Clamp(mx, 0, w), 0, w, 0, -diff)
        end

        DrawTextShadow(self.m_NiceName, x, h - tH - 9)
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

function PANEL:ScanForNPCWeapons()
    if self.HasScanned then return end
    self.HasScanned = true
    for _, v in pairs(list.Get("NPCUsableWeapons")) do
        if v.class == self:GetSpawnName() then
            self:SetIsNPCWeapon(true)
            break
        end
    end
end

function PANEL:PaintOver(w, h)
    self:DrawSelections()
end

function PANEL:ToTable(bigtable)
    local tab = {}
    tab.type = self:GetContentType()
    tab.nicename = self.m_NiceName
    tab.material = self.m_MaterialName
    tab.admin = self:GetAdminOnly()
    tab.spawnname = self:GetSpawnName()
    tab.weapon = self:GetNPCWeapon()
    table.insert(bigtable, tab)
end

function PANEL:Copy()
    local copy = vgui.Create("ContentIcon", self:GetParent())
    copy:SetContentType(self:GetContentType())
    copy:SetSpawnName(self:GetSpawnName())
    copy:SetName(self.m_NiceName)
    copy:SetMaterial(self.m_MaterialName)
    copy:SetNPCWeapon(self:GetNPCWeapon())
    copy:SetAdminOnly(self:GetAdminOnly())
    copy:CopyBase(self)
    copy.DoClick = self.DoClick
    copy.OpenMenu = self.OpenMenu
    copy.OpenMenuExtra = self.OpenMenuExtra
    return copy
end

vgui.Register("ContentIcon", PANEL, "DButton")
function PANEL:Init()
    self.CurrentSearch = ""
    self.OldResults = -1
    self.RebuildResults = false
    self:Dock(TOP)
    self:SetHeight(20)
    self:DockMargin(0, 0, 0, 3)
    self.Search = self:Add("DTextEntry")
    self.Search:Dock(FILL)
    self.Search:SetPlaceholderText("#spawnmenu.search")
    self.Search.OnEnter = function() self:RefreshResults() end
    self.Search.OnFocusChanged = function(_, b) if b then self.ContentPanel:SwitchPanel(self.PropPanel) end end
    self.Search:SetTooltip("#spawnmenu.enter_search")
    local btn = self.Search:Add("DImageButton")
    btn:SetImage("icon16/magnifier.png")
    btn:SetText("")
    btn:Dock(RIGHT)
    btn:DockMargin(4, 2, 4, 2)
    btn:SetSize(16, 16)
    btn:SetTooltip("#spawnmenu.press_search")
    btn.DoClick = function() self:RefreshResults() end
    self.Search.OnKeyCode = function(p, code)
        if code == KEY_F1 then hook.Run("OnSpawnMenuClose") end
        if code == KEY_ESCAPE then hook.Run("OnSpawnMenuClose") end
    end

    self.PropPanel = vgui.Create("ContentContainer", self)
    self.PropPanel:SetVisible(false)
    self.PropPanel:SetTriggerSpawnlistChange(false)
    local Header = self:Add("ContentHeader")
    Header:SetText("#spawnmenu.enter_search")
    self.PropPanel:Add(Header)
end

function PANEL:Paint()
    if self.RebuildResults then
        self.RebuildResults = false
        self:RefreshResults(self.CurrentSearch)
    end
end

function PANEL:SetSearchType(stype, hookname)
    self.m_strSearchType = stype
    hook.Add(hookname, "AddSearchContent_" .. hookname, function(pnlContent, tree, node) self.ContentPanel = pnlContent end)
    hook.Add("SearchUpdate", "SearchUpdate_" .. hookname, function()
        if not g_SpawnMenu:IsVisible() then
            self.RebuildResults = true
            return
        end

        self:RefreshResults(self.CurrentSearch)
    end)

    if hookname ~= "PopulateContent" then return end
    g_SpawnMenu.SearchPropPanel = self.PropPanel
    hook.Add("StartSearch", "StartSearch", function()
        if g_SpawnMenu:IsVisible() then return hook.Run("OnSpawnMenuClose") end
        hook.Run("OnSpawnMenuOpen")
        hook.Run("OnTextEntryGetFocus", self.Search)
        self.Search:RequestFocus()
        self.Search:SetText("")
        timer.Simple(0.1, function() g_SpawnMenu:HangOpen(false) end)
        self.ContentPanel:SwitchPanel(self.PropPanel)
    end)
end

function PANEL:RefreshResults(str)
    if not str then
        self.CurrentSearch = self.Search:GetText()
        str = self.CurrentSearch
        self.OldResults = -1
    else
        if self.ContentPanel.SelectedPanel ~= self.PropPanel then return end
    end

    if not str or str == "" then return end
    local results = search.GetResults(str, self.m_strSearchType, GetConVarNumber("sbox_search_maxresults"))
    for id, result in ipairs(results) do
        if not IsValid(result.icon) then
            ErrorNoHalt("Failed to create icon for " .. (result.words and isstring(result.words[1]) and result.words[1] or result.text) .. "\n")
            continue
        end

        result.icon:SetParent(vgui.GetWorldPanel())
    end

    if self.OldResults == #results then
        for id, result in ipairs(results) do
            if IsValid(result.icon) then result.icon:Remove() end
        end
        return
    end

    self.OldResults = #results
    self.PropPanel:Clear()
    local Header = self:Add("ContentHeader")
    Header:SetText(#results .. " Results for \"" .. str .. "\"")
    self.PropPanel:Add(Header)
    for k, v in ipairs(results) do
        self:AddSearchResult(v.text, v.func, v.icon)
    end

    self.PropPanel:SetParent(self.ContentPanel)
    self.ContentPanel:SwitchPanel(self.PropPanel)
end

function PANEL:AddSearchResult(text, func, icon)
    if not IsValid(icon) then return end
    icon:SetParent(self.PropPanel)
    self.PropPanel:Add(icon)
end

include("contentsidebartoolbox.lua")
local pnlSearch = vgui.RegisterFile("contentsearch.lua")
local PANEL = {}
function PANEL:Init()
    self.Tree = vgui.Create("DTree", self)
    self.Tree:SetClickOnDragHover(true)
    self.Tree.OnNodeSelected = function(Tree, Node) hook.Call("ContentSidebarSelection", GAMEMODE, self:GetParent(), Node) end
    self.Tree:Dock(FILL)
    self.Tree:SetBackgroundColor(Color(240, 240, 240, 255))
    self:SetPaintBackground(false)
end

function PANEL:EnableSearch(stype, hookname)
    self.Search = vgui.CreateFromTable(pnlSearch, self)
    self.Search:SetSearchType(stype, hookname or "PopulateContent")
end

function PANEL:EnableModify()
    self:EnableSearch()
    self:CreateSaveNotification()
    self.Toolbox = vgui.Create("ContentSidebarToolbox", self)
    self.Toolbox:Dock(BOTTOM)
    hook.Add("OpenToolbox", "OpenToolbox", function()
        if not IsValid(self.Toolbox) then return end
        self.Toolbox:Open()
    end)
end

function PANEL:CreateSaveNotification()
    local SavePanel = vgui.Create("Panel", self)
    SavePanel:Dock(TOP)
    SavePanel:SetVisible(false)
    SavePanel:DockMargin(8, 1, 8, 4)
    local SaveButton = vgui.Create("DButton", SavePanel)
    SaveButton:Dock(FILL)
    SaveButton:SetIcon("icon16/disk.png")
    SaveButton:SetText("#spawnmenu.savechanges")
    SaveButton.DoClick = function()
        SavePanel:SlideUp(0.2)
        hook.Run("OnSaveSpawnlist")
    end

    local RevertButton = vgui.Create("DButton", SavePanel)
    RevertButton:Dock(RIGHT)
    RevertButton:SetIcon("icon16/arrow_rotate_clockwise.png")
    RevertButton:SetText("")
    RevertButton:SetTooltip("#spawnmenu.revert_tooptip")
    RevertButton:SetWide(26)
    RevertButton:DockMargin(4, 0, 0, 0)
    RevertButton.DoClick = function()
        SavePanel:SlideUp(0.2)
        hook.Run("OnRevertSpawnlist")
    end

    hook.Add("SpawnlistContentChanged", "ShowSaveButton", function()
        if SavePanel:IsVisible() then return end
        SavePanel:SlideDown(0.2)
        GAMEMODE:AddHint("EditingSpawnlistsSave", 5)
    end)
end

vgui.Register("ContentSidebar", PANEL, "DPanel")
include("contentheader.lua")
local PANEL = {}
Derma_Hook(PANEL, "Paint", "Paint", "Tree")
PANEL.m_bBackground = true
function PANEL:Init()
    self:SetOpenSize(200)
    self:DockPadding(5, 5, 5, 5)
    local label = vgui.Create("DTextEntry", self)
    label:Dock(TOP)
    label:SetZPos(1)
    label:DockMargin(0, 0, 0, 2)
    label:SetTooltip("#spawnmenu.listname_tooltip")
    local panel = vgui.Create("DPanel", self)
    panel:Dock(TOP)
    panel:SetZPos(2)
    panel:SetSize(24, 24)
    panel:DockPadding(2, 2, 2, 2)
    local Button = vgui.Create("DImageButton", panel)
    Button:SetImage("icon16/text_heading_1.png")
    Button:Dock(LEFT)
    Button:SetStretchToFit(false)
    Button:SetSize(20, 20)
    Button:SetCursor("sizeall")
    Button:SetTooltip("#spawnmenu.header_tooltip")
    Button:Droppable("SandboxContentPanel")
    Button.OnDrop = function(s, target)
        local label = vgui.Create("ContentHeader", target)
        return label
    end

    local panel = vgui.Create("Panel", self)
    panel:Dock(FILL)
    panel:SetZPos(3)
    local icon_filter = vgui.Create("DTextEntry", panel)
    icon_filter:Dock(TOP)
    icon_filter:SetUpdateOnType(true)
    icon_filter:SetPlaceholderText("#spawnmenu.quick_filter")
    icon_filter:DockMargin(0, 2, 0, 1)
    local icons = vgui.Create("DIconBrowser", panel)
    icons:Dock(FILL)
    icon_filter.OnValueChange = function(s, str) icons:FilterByText(str) end
    local overlay = vgui.Create("DPanel", self)
    overlay:SetZPos(9999)
    overlay.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200)) end
    self.Overlay = overlay
    hook.Add("ContentSidebarSelection", "SidebarToolboxSelection", function(pnlContent, node)
        if not IsValid(node) or not IsValid(label) or not IsValid(icons) then return end
        if node.CustomSpawnlist then
            label:SetText(node:GetText())
            icons:SelectIcon(node:GetIcon())
            icons:ScrollToSelected()
            overlay:SetVisible(false)
        else
            label:SetText("")
            overlay:SetVisible(true)
        end

        label.OnChange = function()
            if not node.CustomSpawnlist then return end
            node:SetText(label:GetText())
            hook.Run("SpawnlistContentChanged")
        end

        icons.OnChange = function()
            if not node.CustomSpawnlist then return end
            node:SetIcon(icons:GetSelectedIcon())
            hook.Run("SpawnlistContentChanged")
        end
    end)
end

function PANEL:PerformLayout()
    self.Overlay:SetSize(self:GetSize())
end

vgui.Register("ContentSidebarToolbox", PANEL, "DDrawer")
local PANEL = {}
function PANEL:Init()
    self:SetPaintBackground(false)
    self:SetSize(128, 128)
    self:SetText("")
end

function PANEL:OnDepressionChanged(b)
    if IsValid(self.checkbox) then self.checkbox:SetVisible(not b) end
end

function PANEL:Setup(name, icon, label)
    self.label = label
    self.name = name
    self.icon = icon
    self:SetMaterial(icon)
    self:SetName(label or name)
    self.PP = list.Get("PostProcess")[name]
    if not self.PP then return end
    self.DoClick = function()
        if self.PP.onclick then return self.PP.onclick() end
        if not self.PP.cpanel then return end
        if not IsValid(self.cp) then
            self.cp = vgui.Create("ControlPanel")
            self.cp:SetName(name)
            self.PP.cpanel(self.cp)
        end

        spawnmenu.ActivateToolPanel(1, self.cp)
    end

    if self.PP.convar then
        self.checkbox = self:Add("DCheckBox")
        self.checkbox:SetConVar(self.PP.convar)
        self.checkbox:SetSize(20, 20)
        self.checkbox:SetPos(self:GetWide() - 20 - 8, 8)
        self.Enabled = function() return self.checkbox:GetChecked() end
    elseif self.ConVars then
        self.checkbox = self:Add("DCheckBox")
        self.checkbox:SetSize(20, 20)
        self.checkbox:SetPos(self:GetWide() - 20 - 8, 8)
        self.checkbox.OnChange = function(pnl, on)
            for k, v in pairs(self.ConVars) do
                if on then
                    RunConsoleCommand(k, v.on)
                else
                    RunConsoleCommand(k, v.off or "")
                end
            end
        end

        self.checkbox.Think = function(pnl, on)
            local good = true
            for k, v in pairs(self.ConVars) do
                if GetConVarString(k) ~= v.on then good = false end
            end

            pnl:SetChecked(good)
        end

        self.Enabled = function() return self.checkbox:GetChecked() end
    end
end

function PANEL:OpenMenu()
    self:OpenGenericSpawnmenuRightClickMenu()
end

function PANEL:Enabled()
    return false
end

function PANEL:ToTable(bigtable)
    local tab = {}
    tab.type = "postprocess"
    tab.name = self.name
    tab.label = self.label
    tab.icon = self.icon
    tab.convars = self.ConVars
    table.insert(bigtable, tab)
end

function PANEL:Copy()
    local copy = vgui.Create("PostProcessIcon", self:GetParent())
    copy:CopyBounds(self)
    copy.ConVars = self.ConVars
    copy:Setup(self.name, self.icon, self.label)
    return copy
end

vgui.Register("PostProcessIcon", PANEL, "ContentIcon")