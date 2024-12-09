local PANEL = {}
function PANEL:Init()
    self:SetTall(64)
    local function assignClick(panel)
        panel.OnMousePressed = function()
            self.pressing = -1
            self:onClick()
        end

        panel.OnMouseReleased = function()
            if self.pressing then
                self.pressing = nil
                self:onClick()
            end
        end
    end

    self.icon = self:Add("SpawnIcon")
    self.icon:SetSize(128, 64)
    self.icon:InvalidateLayout(true)
    self.icon:Dock(LEFT)
    self.icon.PaintOver = function() end
    assignClick(self.icon)
    self.limit = self:Add("DLabel")
    self.limit:Dock(RIGHT)
    self.limit:SetMouseInputEnabled(true)
    self.limit:SetCursor("hand")
    self.limit:SetExpensiveShadow(1, Color(0, 0, 60))
    self.limit:SetContentAlignment(5)
    self.limit:SetFont("liaMediumFont")
    self.limit:SetWide(64)
    assignClick(self.limit)
    self.label = self:Add("DLabel")
    self.label:Dock(FILL)
    self.label:SetMouseInputEnabled(true)
    self.label:SetCursor("hand")
    self.label:SetExpensiveShadow(1, Color(0, 0, 60))
    self.label:SetContentAlignment(5)
    self.label:SetFont("liaMediumFont")
    self.label:SetTextColor(color_white)
    assignClick(self.label)
end

function PANEL:onClick()
    lia.command.send("beclass", self.class)
    timer.Simple(0.1, function() if IsValid(lia.gui.classes) then lia.gui.classes:loadClasses() end end)
end

function PANEL:setNumber(number)
    local limit = self.data.limit
    if limit > 0 then
        self.limit:SetText(Format("%s/%s", number, limit))
    else
        self.limit:SetText("∞")
    end
end

function PANEL:setClass(data)
    local client = LocalPlayer()
    if data.model then
        local model = data.model
        if istable(model):lower() then model = table.Random(model) end
        self.icon:SetModel(model)
    else
        local character = client:getChar()
        local model = client:GetModel()
        if character then model = character:getModel() end
        self.icon:SetModel(model)
    end

    self.label:SetText(L(data.name))
    self.data = data
    self.class = data.index
    self:setNumber(#lia.class.getPlayers(data.index))
end

vgui.Register("liaClassPanel", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    lia.gui.classes = self
    self:SetSize(self:GetParent():GetSize())
    self.list = vgui.Create("DPanelList", self)
    self.list:Dock(FILL)
    self.list:EnableVerticalScrollbar()
    self.list:SetSpacing(5)
    self.list:SetPadding(5)
    self.classPanels = {}
    self:loadClasses()
end

function PANEL:loadClasses()
    local client = LocalPlayer()
    self.list:Clear()
    self.classPanels = {}
    for k, v in ipairs(lia.class.list) do
        local no, why = lia.class.canBe(client, k)
        local itsFull = "class is full" == why
        if no or itsFull then
            local panel = vgui.Create("liaClassPanel", self.list)
            panel:setClass(v)
            table.insert(self.classPanels, panel)
            self.list:AddItem(panel)
        end
    end
end

vgui.Register("liaClasses", PANEL, "EditablePanel")