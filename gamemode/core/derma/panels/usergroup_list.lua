local PANEL = {}
function PANEL:Init()
    self.groups = {}
    self.selectedGroup = nil
    self.groupButtons = {}
    self.panelColor = lia.color.theme.panel[1]
    self:SetupUI()
end

function PANEL:SetupUI()
    local header = self:Add("DPanel")
    header:Dock(TOP)
    header:SetTall(40)
    header:DockMargin(0, 0, 0, 5)
    header.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
        draw.SimpleText(L("groups"), "liaMediumFont", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.scrollPanel = self:Add("liaScrollPanel")
    self.scrollPanel:Dock(FILL)
end

function PANEL:SetGroups(groups)
    self.groups = groups or {}
    self:RefreshGroups()
end

function PANEL:RefreshGroups()
    self.scrollPanel:Clear()
    self.groupButtons = {}
    local keys = {}
    for g in pairs(self.groups) do
        keys[#keys + 1] = g
    end

    table.sort(keys, function(a, b) return a:lower() < b:lower() end)
    local buttonType = self.buttonType or "liaUserGroupButton"
    for _, groupName in ipairs(keys) do
        local groupData = self.groups[groupName]
        local isDefault = lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[groupName] ~= nil
        local groupBtn
        if buttonType == "liaButton" then
            groupBtn = self.scrollPanel:Add("liaButton")
            groupBtn:Dock(TOP)
            groupBtn:SetTall(50)
            groupBtn:DockMargin(0, 0, 0, 5)
            groupBtn:SetTxt(groupName)
            groupBtn:SetRadius(8)
            groupBtn.selected = false
            groupBtn.groupName = groupName
            groupBtn.isDefault = isDefault
            groupBtn.Paint = function(s, w, h)
                local bgColor = lia.color.theme.panel[1]
                local textColor = lia.color.theme.text
                local accentColor = lia.config.get("Color")
                if s.selected then
                    bgColor = ColorAlpha(accentColor, 30)
                    textColor = accentColor
                elseif s:IsHovered() then
                    bgColor = ColorAlpha(accentColor, 15)
                end

                lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
                if s.selected then lia.derma.rect(0, 0, w, h):Rad(8):Color(accentColor):Shape(lia.derma.SHAPE_IOS):Outline(2):Draw() end
                draw.SimpleText(s.text, "liaMediumFont", 15, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        else
            groupBtn = self.scrollPanel:Add("liaUserGroupButton")
            groupBtn:Dock(TOP)
            groupBtn:SetTall(50)
            groupBtn:DockMargin(0, 0, 0, 5)
            groupBtn:SetGroup(groupName, groupData, isDefault)
        end

        groupBtn.DoClick = function() self:SelectGroup(groupName) end
        self.groupButtons[groupName] = groupBtn
    end
end

function PANEL:SelectGroup(groupName)
    local buttonType = self.buttonType or "liaUserGroupButton"
    if self.selectedGroup and self.groupButtons[self.selectedGroup] then
        local prevBtn = self.groupButtons[self.selectedGroup]
        if buttonType == "liaButton" then
            prevBtn.selected = false
        else
            prevBtn:SetSelected(false)
        end
    end

    self.selectedGroup = groupName
    if self.groupButtons[groupName] then
        local newBtn = self.groupButtons[groupName]
        if buttonType == "liaButton" then
            newBtn.selected = true
        else
            newBtn:SetSelected(true)
        end
    end

    if self.OnGroupSelected then self:OnGroupSelected(groupName) end
end

function PANEL:GetSelectedGroup()
    return self.selectedGroup
end

function PANEL:Paint(w, h)
    lia.derma.rect(0, 0, w, h):Rad(12):Color(self.panelColor):Shape(lia.derma.SHAPE_IOS):Draw()
end

vgui.Register("liaUserGroupList", PANEL, "DPanel")
