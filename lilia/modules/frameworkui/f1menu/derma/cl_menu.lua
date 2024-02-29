---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local PANEL = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local gradient = lia.util.getMaterial("vgui/gradient-u")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:Init()
    if MODULE.F1ThirdPersonEnabled then
        self.initialValues = {
            ThirdPerson = GetConVar("tp_enabled"):GetInt(),
            ThirdPersonVerticalView = GetConVar("tp_vertical"):GetInt(),
            ThirdPersonHorizontalView = GetConVar("tp_horizontal"):GetInt(),
            ThirdPersonViewDistance = GetConVar("tp_distance"):GetInt(),
            ClassicThirdPerson = GetConVar("tp_classic"):GetInt()
        }

        ThirdPerson = GetConVar("tp_enabled")
        ThirdPersonVerticalView = GetConVar("tp_vertical")
        ThirdPersonHorizontalView = GetConVar("tp_horizontal")
        ThirdPersonViewDistance = GetConVar("tp_distance")
        ClassicThirdPerson = GetConVar("tp_classic")
        if ThirdPerson:GetInt() ~= 1 then
            wasThirdPerson = false
            RunConsoleCommand("tp_enabled", "1")
        else
            wasThirdPerson = true
        end

        if ClassicThirdPerson:GetInt() == 1 then
            wasClassic = true
            RunConsoleCommand("tp_classic", "0")
        else
            wasClassic = false
        end

        ThirdPersonVerticalView:SetInt(0)
        ThirdPersonHorizontalView:SetInt(0)
        ThirdPersonViewDistance:SetInt(100)
    end

    if MODULE.F1DisplayModel then
        self.model = self:Add("liaModelPanel")
        self.model:SetWide(ScrW() * 0.25)
        self.model:Dock(LEFT)
        self.model:SetFOV(50)
        self.model:SetTall(self:GetTall())
        self.model.enableHook = true
        self.model.copyLocalSequence = true
        self.model:SetModel(LocalPlayer():GetModel())
        self.model.Entity:SetSkin(LocalPlayer():GetSkin())
        for _, v in ipairs(LocalPlayer():GetBodyGroups()) do
            self.model.Entity:SetBodygroup(v.id, LocalPlayer():GetBodygroup(v.id))
        end

        local ent = self.model.Entity
        if ent and IsValid(ent) then
            local mats = LocalPlayer():GetMaterials()
            for k, _ in pairs(mats) do
                ent:SetSubMaterial(k - 1, LocalPlayer():GetSubMaterial(k - 1))
            end
        end
    end

    lia.gui.menu = self
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetPopupStayAtBack(true)
    self.tabs = self:Add("DHorizontalScroller")
    self.tabs:SetWide(0)
    self.tabs:SetTall(86)
    self.panel = self:Add("EditablePanel")
    self.panel:SetSize(ScrW() * 0.6, ScrH() * 0.65)
    self.panel:Center()
    self.panel:SetPos(self.panel.x, self.panel.y + 72)
    self.panel:SetAlpha(0)
    self.title = self:Add("DLabel")
    self.title:SetPos(self.panel.x, self.panel.y - 80)
    self.title:SetTextColor(color_white)
    self.title:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.title:SetFont("liaTitleFont")
    self.title:SetText("")
    self.title:SetAlpha(0)
    self.title:SetSize(self.panel:GetWide(), 72)
    local tabs = {}
    hook.Run("CreateMenuButtons", tabs)
    self.tabList = {}
    for name, callback in SortedPairs(tabs) do
        if type(callback) == "string" then
            local body = callback
            if body:sub(1, 4) == "http" then
                callback = function(panel)
                    local html = panel:Add("DHTML")
                    html:Dock(FILL)
                    html:OpenURL(body)
                end
            else
                callback = function(panel)
                    local html = panel:Add("DHTML")
                    html:Dock(FILL)
                    html:SetHTML(body)
                end
            end
        end

        local tab = self:addTab(L(name), callback, name)
        self.tabList[name] = tab
    end

    self.noAnchor = CurTime() + .4
    self.anchorMode = true
    self:MakePopup()
    self.info = vgui.Create("liaCharInfo", self)
    self.info:setup()
    self.info:SetAlpha(0)
    self.info:AlphaTo(255, 0.5)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:OnKeyCodePressed(key)
    self.noAnchor = CurTime() + .5
    if key == KEY_F1 then self:remove() end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:Update()
    self:Remove()
    vgui.Create("liaMenu")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:Think()
    local key = input.IsKeyDown(KEY_F1)
    if key and (self.noAnchor or CurTime() + .4) < CurTime() and self.anchorMode == true then
        self.anchorMode = false
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    if not self.anchorMode then
        if IsValid(self.info) then return end
        if not key then self:remove() end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(0, 0, w, h)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:addTab(name, callback, uniqueID)
    name = L(name)
    local function paintTab(tab, w, h)
        if self.activeTab == tab then
            surface.SetDrawColor(ColorAlpha(lia.config.Color, 200))
            surface.DrawRect(0, h - 8, w, 8)
        elseif tab.Hovered then
            surface.SetDrawColor(0, 0, 0, 50)
            surface.DrawRect(0, h - 8, w, 8)
        end
    end

    surface.SetFont("liaMenuButtonLightFont")
    local w = surface.GetTextSize(name)
    local tab = self.tabs:Add("DButton")
    tab:SetSize(0, self.tabs:GetTall())
    tab:SetText(name)
    tab:SetPos(self.tabs:GetWide(), 0)
    tab:SetTextColor(Color(250, 250, 250))
    tab:SetFont("liaMenuButtonLightFont")
    tab:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    tab:SizeToContentsX()
    tab:SetWide(w + 32)
    tab.Paint = paintTab
    tab.DoClick = function(this)
        if IsValid(lia.gui.info) then lia.gui.info:Remove() end
        self.panel:Clear()
        self.title:SetText(this:GetText())
        self.title:SizeToContentsY()
        self.title:AlphaTo(255, 0.5)
        self.title:MoveAbove(self.panel, 8)
        self.panel:AlphaTo(255, 0.5, 0.1)
        self.activeTab = this
        lastMenuTab = uniqueID
        if callback then callback(self.panel, this) end
    end

    self.tabs:AddPanel(tab)
    self.tabs:SetWide(math.min(self.tabs:GetWide() + tab:GetWide(), ScrW()))
    self.tabs:SetPos((ScrW() * 0.5) - (self.tabs:GetWide() * 0.5), 0)
    return tab
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:setActiveTab(key)
    if IsValid(self.tabList[key]) then self.tabList[key]:DoClick() end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:OnRemove()
    if MODULE.F1ThirdPersonEnabled then self:RestoreConVars() end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:RestoreConVars()
    RunConsoleCommand("tp_enabled", tostring(self.initialValues.ThirdPerson))
    RunConsoleCommand("tp_vertical", tostring(self.initialValues.ThirdPersonVerticalView))
    RunConsoleCommand("tp_horizontal", tostring(self.initialValues.ThirdPersonHorizontalView))
    RunConsoleCommand("tp_distance", tostring(self.initialValues.ThirdPersonViewDistance))
    RunConsoleCommand("tp_classic", tostring(self.initialValues.ClassicThirdPerson))
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PANEL:remove()
    CloseDermaMenus()
    if not self.closing then
        self:AlphaTo(0, 0.25, 0, function()
            if MODULE.F1ThirdPersonEnabled then self:RestoreConVars() end
            self:Remove()
        end)

        self.closing = true
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
vgui.Register("liaMenu", PANEL, "EditablePanel")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
if IsValid(lia.gui.menu) then vgui.Create("liaMenu") end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
