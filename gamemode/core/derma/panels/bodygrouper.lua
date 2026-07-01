local PANEL = {}
AccessorFunc(PANEL, "m_eTarget", "Target")
local leftrotate, rightrotate = input.LookupBinding("+moveleft"), input.LookupBinding("+moveright")
local leftinput, rightinput = input.GetKeyCode(leftrotate), input.GetKeyCode(rightrotate)
function PANEL:GetPreviewEntity()
    return lia.view.getEntity(self)
end

function PANEL:GetCurrentBodygroups()
    local model = self:GetPreviewEntity()
    if not IsValid(model) then return {} end
    local groups = {}
    for i = 0, model:GetNumBodyGroups() - 1 do
        groups[i] = model:GetBodygroup(i)
    end
    return groups
end

function PANEL:BuildBodygroupExport()
    local lines = {"{"}
    local groups = self:GetCurrentBodygroups()
    local ids = {}
    for id in pairs(groups) do
        ids[#ids + 1] = id
    end

    table.sort(ids, function(a, b) return tonumber(a) < tonumber(b) end)
    for _, id in ipairs(ids) do
        lines[#lines + 1] = "    [" .. tostring(id) .. "] = " .. tostring(groups[id]) .. ","
    end

    lines[#lines + 1] = "}"
    return table.concat(lines, "\n")
end

function PANEL:Init()
    self:SetSize(math.min(440, ScrW() * 0.28), math.min(ScrH() * 0.75, 760))
    self:SetPos(ScrW() - self:GetWide() - 48, math.max(48, (ScrH() - self:GetTall()) * 0.5))
    self:MakePopup()
    self:SetBackgroundBlur(false)
    self:SetTitle(L("bodygroupMenuTitle"))
    self:DockPadding(8, 32, 8, 8)
    self.previewInfo = self:Add("DPanel")
    self.previewInfo:Dock(TOP)
    self.previewInfo:DockMargin(0, 0, 0, 8)
    self.previewInfo:SetTall(56)
    self.previewInfo.Paint = function(panel, panelWidth, h)
        local str = L("rotateInstruction", leftrotate:upper(), rightrotate:upper())
        lia.util.drawText(L("bodygroupMenuTitle"), panelWidth / 2, 18, Color(255, 255, 255), 1, 1, "LiliaFont.18")
        lia.util.drawText(str, panelWidth / 2, 38, Color(220, 220, 220), 1, 1, "LiliaFont.16")
    end

    self.side = self:Add("Panel")
    self.side:Dock(FILL)
    self.side:DockPadding(5, 5, 5, 5)
    self.skinSelector = self.side:Add("liaSlideBox")
    self.skinSelector:Dock(TOP)
    self.skinSelector:DockMargin(0, 0, 0, 5)
    self.skinSelector:SetText(L("skin"))
    self.skinSelector:SetRange(0, 0, 0)
    self.skinSelector:SetVisible(false)
    self.skinSelector.OnValueChanged = function(_, value)
        local model = self:GetPreviewEntity()
        if IsValid(model) then model:SetSkin(math.Round(value)) end
    end

    self.actions = self.side:Add("Panel")
    self.actions:Dock(BOTTOM)
    self.actions:DockMargin(0, 5, 0, 0)
    self.actions:SetTall(24)
    self.copyBodygroups = self.actions:Add("liaButton")
    self.copyBodygroups:Dock(LEFT)
    self.copyBodygroups:SetWide(160)
    self.copyBodygroups:SetText(L("copyBodygroups"))
    self.copyBodygroups.DoClick = function()
        local export = self:BuildBodygroupExport()
        SetClipboardText(export)
        MsgC(Color(0, 255, 0), "[Lilia] ", color_white, export .. "\n")
        LocalPlayer():notifySuccessLocalized("copied")
    end

    self.submit = self.actions:Add("liaButton")
    self.submit:Dock(FILL)
    self.submit:DockMargin(5, 0, 0, 0)
    self.submit:SetText(L("submit"))
    self.submit.DoClick = function()
        local model = self:GetPreviewEntity()
        if IsValid(model) then
            local skn = model:GetSkin()
            local groups = self:GetCurrentBodygroups()
            local makeChange = true
            if self.originalSkin == skn then makeChange = false end
            if not makeChange then
                for i = 0, model:GetNumBodyGroups() - 1 do
                    if self.originalBodygroups[i] ~= groups[i] then
                        makeChange = true
                        break
                    end
                end
            end

            if makeChange then
                net.Start("BodygrouperMenu")
                net.WriteEntity(self:GetTarget())
                net.WriteUInt(skn, 10)
                net.WriteTable(groups)
                net.SendToServer()
            end
        end
    end

    self.scroll = self.side:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
end

function PANEL:OnClose()
    net.Start("BodygrouperMenuClose")
    net.SendToServer()
    lia.view.close(self)
end

function PANEL:PopulateOptions()
    local target = self:GetTarget()
    if not IsValid(target) then return end
    self.scroll:Clear()
    if target:SkinCount() > 1 then
        self.skinSelector:SetRange(0, target:SkinCount() - 1, 0)
        self.skinSelector:SetValue(target:GetSkin())
        self.skinSelector:SetVisible(true)
    else
        self.skinSelector:SetVisible(false)
    end

    if target:GetNumBodyGroups() > 1 then
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) <= 1 then continue end
            local group = target:GetBodygroup(i)
            local panel = vgui.Create("liaSlideBox", self.scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetText(target:GetBodygroupName(i):sub(1, 1):upper() .. target:GetBodygroupName(i):sub(2))
            panel:SetRange(0, target:GetBodygroupCount(i) - 1, 0)
            panel:SetValue(group)
            panel.OnValueChanged = function(_, value)
                local model = self:GetPreviewEntity()
                if IsValid(model) then model:SetBodygroup(i, math.Round(value)) end
            end
        end
    elseif not self.skinSelector:IsVisible() then
        local info = self.scroll:Add("DLabel")
        info:Dock(TOP)
        info:DockMargin(0, 10, 0, 0)
        info:SetText(L("noBodygroupsnSkins"))
        info:SetFont("liaMediumFont")
        info:SetTextColor(color_white)
        info:SetContentAlignment(5)
        info:SetWrap(true)
        info:SetAutoStretchVertical(true)
        info:SetTall(40)
    end
end

function PANEL:SetTarget(target)
    self.m_eTarget = target
    lia.view.begin(self, {
        context = target,
        hideEntities = {target, LocalPlayer()}
    })

    lia.view.setModel(self, target:GetModel(), {
        skin = target:GetSkin(),
        bodygroups = lia.util.resolveBodygroups(target, {}),
        context = target
    })

    local entity = self:GetPreviewEntity()
    if IsValid(entity) then
        self.originalSkin = target:GetSkin()
        entity:SetSkin(target:GetSkin())
        self.originalBodygroups = {}
        for i = 0, entity:GetNumBodyGroups() - 1 do
            self.originalBodygroups[i] = target:GetBodygroup(i)
            entity:SetBodygroup(i, target:GetBodygroup(i))
        end
    end

    self:PopulateOptions()
end

function PANEL:Think()
    if input.IsKeyDown(leftinput) then
        lia.view.rotate(self, FrameTime() * 180)
    elseif input.IsKeyDown(rightinput) then
        lia.view.rotate(self, FrameTime() * -180)
    end
end

function PANEL:OnRemove()
    lia.view.close(self)
end

vgui.Register("BodygrouperMenu", PANEL, "liaFrame")
