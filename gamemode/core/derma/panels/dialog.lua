local PANEL = {}
function PANEL:Init()
    if IsValid(lia.dialog.vgui) then lia.dialog.vgui:Remove() end
    lia.dialog.vgui = self
    self:SetTitle("Dialog")
    self:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    self:Center()
    self:ShowCloseButton(true)
    self:MakePopup()
    self:SetDraggable(true)
    self:SetMouseInputEnabled(true)
    self.modelDisplay = self:Add("DModelPanel")
    self.modelDisplay:Dock(LEFT)
    self.modelDisplay:SetWide(self:GetWide() / 3)
    self.modelDisplay:SetZPos(1)
    self.modelDisplay:SetFOV(28)
    self.modelDisplay:SetCamPos(Vector(50, 0, 64))
    self.modelDisplay:SetLookAt(Vector(0, 0, 64))
    self.modelDisplay:SetModel("models/Barney.mdl")
    function self.modelDisplay:LayoutEntity()
        return
    end

    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:SetZPos(2)
    self.dialogText = self.content:Add("DLabel")
    self.dialogText:Dock(TOP)
    self.dialogText:DockMargin(2, 2, 2, 2)
    self.dialogText:SetZPos(3)
    self.dialogText:SetFont("LiliaFont.32")
    self.dialogText:SetAutoStretchVertical(true)
    self.dialogText:SetWrap(true)
    self.dialogText:SetText("")
    self.dialogOptions = self.content:Add("DScrollPanel")
    self.dialogOptions:Dock(FILL)
    self.dialogOptions:DockMargin(0, 0, 0, 0)
    self.dialogOptions:SetZPos(4)
    self:SizeToContentsY()
end

function PANEL:SizeToContentsY()
    local children = self.dialogOptions:GetCanvas():GetChildren()
    local maxHeight = 8 + self.dialogText:GetTall()
    if children and #children > 0 then
        for _, dialog in ipairs(children) do
            maxHeight = maxHeight + dialog:GetTall() + 4
        end
    end

    local minHeight = ScrH() * 0.7
    if maxHeight < minHeight then maxHeight = minHeight end
    local maxScreenHeight = ScrH() * 0.95
    if maxHeight > maxScreenHeight then
        maxHeight = maxScreenHeight
        self.scrollable = true
    else
        self.scrollable = false
    end

    self:SetTall(maxHeight)
    self:Center()
end

function PANEL:SetDialogText(text)
    self.dialogText:SetText(text or "")
    self:InvalidateLayout(true)
end

function PANEL:SetDialogTitle(title)
    self:SetTitle(title or "Dialog")
end

function PANEL:ClearDialogOptions()
    self.dialogOptions:Clear()
end

function PANEL:AddDialogOptions(options, npc)
    local ply = LocalPlayer()
    if isfunction(options) then options = options(ply, npc) end
    local validOptions = {}
    for label, info in pairs(options) do
        table.insert(validOptions, {
            label = label,
            info = info
        })
    end

    table.sort(validOptions, function(a, b)
        local labelA = a.label:lower()
        local labelB = b.label:lower()
        local aIsAdmin = labelA:find("^%[admin%]") or labelA:find("^%[admin%]:")
        local bIsAdmin = labelB:find("^%[admin%]") or labelB:find("^%[admin%]:")
        if aIsAdmin and not bIsAdmin then return true end
        if bIsAdmin and not aIsAdmin then return false end
        local aIsGoodbye = (labelA == "goodbye") or (labelA == "bye") or (labelA == "farewell")
        local bIsGoodbye = labelB == "goodbye" or labelB == "bye" or labelB == "farewell"
        if aIsGoodbye and not bIsGoodbye then return false end
        if bIsGoodbye and not aIsGoodbye then return true end
        return a.label < b.label
    end)

    for _, option in ipairs(validOptions) do
        local label = option.label
        local info = option.info
        local choiceBtn = self.dialogOptions:Add("liaSmallButton")
        choiceBtn:Dock(TOP)
        choiceBtn:DockMargin(6, 4, 6, 0)
        choiceBtn:SetTall(45)
        choiceBtn:SetText(label)
        choiceBtn:SetFont("LiliaFont.32")
        choiceBtn.DoClick = function()
            if info.Callback and not info.serverOnly then info.Callback(ply, npc) end
            if info.serverOnly then
                net.Start("liaNpcDialogServerCallback")
                net.WriteEntity(npc)
                net.WriteString(label)
                net.SendToServer()
            end

            if info.options then
                local nextOptions = info.options
                if isfunction(nextOptions) then nextOptions = nextOptions(ply, npc) end
                if nextOptions and istable(nextOptions) then
                    self:ClearDialogOptions()
                    self:AddDialogOptions(nextOptions, npc)
                else
                    if IsValid(self) then self:Remove() end
                end
            else
                if IsValid(self) then self:Remove() end
            end
        end
    end
end

function PANEL:LoadNPCDialog(convoSettings, npc)
    if not convoSettings then return end
    self:SetDialogText("")
    self:ClearDialogOptions()
    if convoSettings.Conversation then self:AddDialogOptions(convoSettings.Conversation, npc) end
end

function PANEL:OnMouseWheeled(scrollDelta)
    if not self.scrollable then return end
    if IsValid(self.dialogOptions) then
        local scrollBar = self.dialogOptions:GetVBar()
        if IsValid(scrollBar) then
            local currentScroll = scrollBar:GetScroll()
            local scrollAmount = scrollDelta * 20
            scrollBar:SetScroll(currentScroll - scrollAmount)
        end
    end
end

vgui.Register("DialogMenu", PANEL, "liaFrame")
