local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.info) then lia.gui.info:Remove() end
    lia.gui.info = self
    self:SetSize(ScrW() * 0.6, ScrH() * 0.7)
    self:Dock(FILL)
    self:DockMargin(0, 100, 0, 0)
    local suppress = hook.Run("CanCreateCharInfo", self)
    if not suppress or (suppress and not suppress.all) then
        if not suppress or not suppress.model then
            self.model = self:Add("liaModelPanel")
            self.model:SetSize(ScrW() * 0.25, ScrH() * 0.325)
            self.model:SetPos(ScrW() * 0.375, ScrH() * 0.08)
            self.model:SetFOV(75)
            self.model.enableHook = true
            self.model.copyLocalSequence = true
        end

        if not suppress or not suppress.info then
            self.info = self:Add("DPanel")
            self.info:SetSize(ScrW() * 0.4, ScrH() * 0.4)
            self.info:SetPos(ScrW() * 0.3, ScrH() - ScrH() * 0.4 - ScrH() * 0.2)
            self.info:SetDrawBackground(false)
        end

        if not suppress or not suppress.name then
            self.name = self.info:Add("DLabel")
            self.name:SetFont("liaHugeFont")
            self.name:SetTall(72)
            self.name:Dock(TOP)
            self.name:DockMargin(0, 0, 0, 4)
            self.name:SetTextColor(color_white)
            self.name:SetExpensiveShadow(1, Color(0, 0, 0, 150))
        end

        if not suppress or not suppress.desc then
            self.desc = self.info:Add("DTextEntry")
            self.desc:Dock(TOP)
            self.desc:SetFont("liaMediumLightFont")
            self.desc:SetTall(28)
            self.descReset = self.info:Add("DButton")
            self.descReset:Dock(TOP)
            self.descReset:SetFont("liaMediumLightFont")
            self.descReset:SetTall(28)
            self.descReset:SetText("Generate a Description")
            self.descReset:SetTextColor(color_white)
        end

        if not suppress or not suppress.money then
            self.money = self.info:Add("DLabel")
            self.money:Dock(TOP)
            self.money:SetFont("liaMediumFont")
            self.money:SetTextColor(color_white)
            self.money:SetExpensiveShadow(1, Color(0, 0, 0, 150))
            self.money:DockMargin(0, 10, 0, 0)
        end

        if not suppress or not suppress.faction then
            self.faction = self.info:Add("DLabel")
            self.faction:Dock(TOP)
            self.faction:SetFont("liaMediumFont")
            self.faction:SetTextColor(color_white)
            self.faction:SetExpensiveShadow(1, Color(0, 0, 0, 150))
            self.faction:DockMargin(0, 10, 0, 0)
        end

        if not suppress or not suppress.class then
            local class = lia.class.list[LocalPlayer():getChar():getClass()]
            if class then
                self.class = self.info:Add("DLabel")
                self.class:Dock(TOP)
                self.class:SetFont("liaMediumFont")
                self.class:SetTextColor(color_white)
                self.class:SetExpensiveShadow(1, Color(0, 0, 0, 150))
                self.class:DockMargin(0, 10, 0, 0)
            end
        end

        hook.Run("CreateCharInfoText", self, suppress)
    end

    hook.Run("CreateCharInfo", self)
end

function PANEL:setup()
    local char = LocalPlayer():getChar()
    if self.desc then
        self.desc:SetText(char:getDesc():gsub("#", "\226\128\139#"))
        self.desc.OnEnter = function(this)
            local newDesc = this:GetText():gsub("\226\128\139#", "#")
            Derma_Query("Are you sure you want to modify your characters description?", "Change Description", "Yes", function() lia.command.send("chardesc", newDesc) end, "No")
        end
    end

    if self.descReset then
        self.descReset.DoClick = function()
            lia.gui.menu:Remove()
            F1MenuCore:OpenDescGenerator()
        end
    end

    if self.name then
        self.name:SetText(LocalPlayer():Name():gsub("#", "\226\128\139#"))
        hook.Add(
            "OnCharVarChanged",
            self,
            function(_, character, key, _, value)
                if char ~= character then return end
                if key ~= "name" then return end
                self.name:SetText(value:gsub("#", "\226\128\139#"))
            end
        )
    end

    if self.money then self.money:SetText(L("charMoney", lia.currency.get(char:getMoney()))) end
    if self.faction then self.faction:SetText(L("charFaction", L(team.GetName(LocalPlayer():Team())))) end
    if self.class then
        local class = lia.class.list[char:getClass()]
        if class then self.class:SetText(L("charClass", L(class.name))) end
    end

    if self.model then
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

    hook.Run("OnCharInfoSetup", self)
end

function PANEL:Paint()
end

vgui.Register("liaCharInfo", PANEL, "EditablePanel")
