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
    self.nameLabel:SetFont("LiliaFont.30b")
    self.nameLabel:SetTextColor(color_white)
    self.nameLabel:SetContentAlignment(5)
    self.nameLabel:Dock(TOP)
    self.infoScroll = vgui.Create("liaScrollPanel", self)
    self.infoScroll:Dock(TOP)
    self.infoScroll:InvalidateLayout(true)
    if not IsValid(self.infoScroll.VBar) then self.infoScroll:PerformLayout() end
    self.infoScroll:SetTall(self:GetTall() * 0.55)
    self.btnArea = vgui.Create("EditablePanel", self)
    self.btnArea:Dock(BOTTOM)
    self.btnArea:SetWide(self:GetWide() * 0.4)
end
function PANEL:addBtn(text, cb)
    local btn = vgui.Create("liaMediumButton", self.btnArea)
    btn:SetFont("LiliaFont.28b")
    btn:SetText(text)
    btn:SetTall(50)
    btn:Dock(TOP)
    btn:DockMargin(0, 0, 0, 8)
    btn.DoClick = cb
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
                net.Start("liaInvAct")
                net.WriteString(key)
                net.WriteType(self.ent)
                net.WriteType(nil)
                net.SendToServer()
            end
            self:Remove()
        end)
    end
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