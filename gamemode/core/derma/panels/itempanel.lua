local PANEL = {}
function PANEL:Init()
    local sw, sh = ScrW(), ScrH()
    self:SetSize(sw * 0.6, sh * 0.8)
    self:Center()
    self:MakePopup()
    lia.gui.itemPanel = self
    self.header = vgui.Create("EditablePanel", self)
    self.header:Dock(TOP)
    self.nameLabel = vgui.Create("DLabel", self.header)
    self.nameLabel:SetFont("liaBigTitle")
    self.nameLabel:SetTextColor(color_white)
    self.nameLabel:SetContentAlignment(5)
    self.nameLabel:Dock(TOP)
    self.infoScroll = vgui.Create("DScrollPanel", self)
    self.infoScroll:Dock(TOP)
    self.infoScroll:SetTall(self:GetTall() * 0.55)
    self.btnArea = vgui.Create("EditablePanel", self)
    self.btnArea:Dock(BOTTOM)
    self.btnArea:SetWide(self:GetWide() * 0.4)
end

local function drawLine(parent, title, val)
    local t = parent:Add("DLabel")
    t:Dock(TOP)
    t:SetFont("liaBigTitle")
    t:SetTextColor(color_white)
    t:SetText(title)
    t:SizeToContentsY()
    local v = parent:Add("DLabel")
    v:Dock(TOP)
    v:DockMargin(0, 2, 0, 10)
    v:SetFont("liaBigText")
    v:SetTextColor(color_white)
    v:SetWrap(true)
    v:SetText(val ~= "" and val or "—")
    timer.Simple(0, function()
        if IsValid(v) then
            v:SetWide(parent:GetWide() - 20)
            v:SizeToContentsY()
        end
    end)
end

function PANEL:addBtn(text, cb)
    local btn = vgui.Create("liaMediumButton", self.btnArea)
    btn:SetFont("liaBigBtn")
    btn:SetText(text)
    btn:SetTall(50)
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, 8)
    btn.DoClick = cb
end

function PANEL:openInspect()
    if IsValid(self.inspectOverlay) then self.inspectOverlay:Remove() end
    local overlay = vgui.Create("EditablePanel")
    self.inspectOverlay = overlay
    overlay:SetSize(ScrW(), ScrH())
    overlay:MakePopup()
    overlay:SetKeyboardInputEnabled(true)
    local frame = vgui.Create("DFrame", overlay)
    self.inspectFrame = frame
    local fw, fh = ScrW() * 0.45, ScrH() * 0.8
    frame:SetSize(fw, fh)
    frame:Center()
    frame:SetTitle(L("inspect"))
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    frame.OnClose = function() if IsValid(overlay) then overlay:Remove() end end
    local hint = vgui.Create("DLabel", frame)
    hint:Dock(TOP)
    hint:SetTall(40)
    hint:SetContentAlignment(5)
    hint:SetFont("liaBigText")
    hint:SetTextColor(color_white)
    hint:SetText(L("itemInspectHint"))
    local view = vgui.Create("EditablePanel", frame)
    view:Dock(TOP)
    view:SetTall(fh * 0.5)
    local model = vgui.Create("DModelPanel", view)
    model:Dock(FILL)
    model:SetModel(self.item.model or "models/props_junk/cardboard_box002b.mdl")
    model.LayoutEntity = function() end
    timer.Simple(0, function()
        if not IsValid(model) then return end
        local mn, mx = model.Entity:GetRenderBounds()
        local c = (mn + mx) * 0.5
        local r = (mx - mn):Length() * 0.5 + 4
        model:SetLookAt(c)
        local d = (model:GetCamPos() - c):Length()
        model:SetFOV(math.Clamp(math.deg(2 * math.asin(r / d)), 20, 80))
    end)

    model.OnMouseWheeled = function() end
    model.Think = function(p)
        if input.IsKeyDown(KEY_A) or input.IsKeyDown(KEY_D) then
            local ang = p.Entity:GetAngles()
            ang.y = ang.y + FrameTime() * 150 * (input.IsKeyDown(KEY_A) and 1 or -1)
            p.Entity:SetAngles(ang)
        end
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    drawLine(scroll, L("name"), self.item:getName() or "")
    local extra = {}
    hook.Run("DisplayItemRelevantInfo", extra, LocalPlayer(), self.item)
    for _, info in ipairs(extra) do
        if info.title and info.value then
            local v = isfunction(info.value) and info.value(LocalPlayer(), self.item) or tostring(info.value)
            drawLine(scroll, info.title, v)
        end
    end

    if LocalPlayer():isStaffOnDuty() or LocalPlayer():hasPrivilege(L("canAccessItemInformations")) then
        local cr = self.ent:GetCreator()
        if IsValid(cr) then drawLine(scroll, L("spawner"), cr:Name() .. " - " .. cr:SteamID()) end
    end
end

function PANEL:buildButtons()
    self.btnArea:Clear()
    for key, fn in SortedPairs(self.item.functions) do
        if key == "combine" then continue end
        if hook.Run("CanRunItemAction", self.item, key) == false then continue end
        if isfunction(fn.onCanRun) and not fn.onCanRun(self.item) then continue end
        self:addBtn(L(fn.name or key), function()
            if fn.sound then surface.PlaySound(fn.sound) end
            if not fn.onClick or fn.onClick(self.item) ~= false then
                net.Start("invAct")
                net.WriteString(key)
                net.WriteType(self.ent)
                net.SendToServer()
            end

            self:Remove()
        end)
    end

    self:addBtn(L("inspect"), function()
        if hook.Run("CanPlayerInspectItem", LocalPlayer(), self.item) ~= false then self:openInspect() end
        self:Remove()
    end)

    self:addBtn(L("exit"), function() self:Remove() end)
    local h = 0
    for _, c in ipairs(self.btnArea:GetChildren()) do
        h = h + c:GetTall() + 8
    end

    self.btnArea:SetTall(h)
    self.btnArea:SetPos((self:GetWide() - self.btnArea:GetWide()) * 0.5, self:GetTall() - h - 20)
end

function PANEL:SetEntity(ent)
    self.ent = ent
    self.item = ent:getItemTable()
    if not self.item then
        self:Remove()
        return
    end

    self.item.player = LocalPlayer()
    self.item.entity = ent
    self.nameLabel:SetText(self.item:getName() or "")
    self.nameLabel:SizeToContentsY()
    self.header:SetTall(self.nameLabel:GetTall())
    self:buildButtons()
    hook.Run("ItemPanelOpened", self, ent)
end

function PANEL:Think()
    if not IsValid(self.ent) or LocalPlayer():GetPos():DistToSqr(self.ent:GetPos()) > 9216 then self:Remove() end
end

function PANEL:OnRemove()
    if self.item then
        self.item.player = nil
        self.item.entity = nil
    end

    hook.Run("ItemPanelClosed", self, self.ent)
    lia.gui.itemPanel = nil
end

vgui.Register("liaItemMenu", PANEL, "EditablePanel")
