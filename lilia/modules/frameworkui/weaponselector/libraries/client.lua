WepSelectInvert = CreateClientConVar("wepselect_invert", 0, true)
MODULE.lastSlot = MODULE.lastSlot or 1
MODULE.lifeTime = MODULE.lifeTime or 0
MODULE.deathTime = MODULE.deathTime or 0
local LIFE_TIME = 4
local DEATH_TIME = 5
function MODULE:OnSlotChanged()
    local client = LocalPlayer()
    self.lifeTime = CurTime() + LIFE_TIME
    self.deathTime = CurTime() + DEATH_TIME
    for k, v in SortedPairs(client:GetWeapons()) do
        if k == self.lastSlot then
            if v.Instructions and string.find(v.Instructions, "%S") then
                self.markup = markup.Parse("<font=liaItemBoldFont>" .. v.Instructions .. "</font>")
                return
            else
                self.markup = nil
            end
        end
    end
end

function MODULE:SetupQuickMenu(menu)
    menu:addCheck("Invert direction of weapon selection scroll", function(_, state)
        if state then
            RunConsoleCommand("wepselect_invert", "1")
        else
            RunConsoleCommand("wepselect_invert", "0")
        end
    end, WepSelectInvert:GetBool())

    menu:addSpacer()
end

function MODULE:PlayerBindPress(client, bind, pressed)
    local invprev, invnext = isnumber(bind:find("invprev")), isnumber(bind:find("invnext"))
    local weapon = client:GetActiveWeapon()
    if not client:hasValidVehicle() and (not IsValid(weapon) or weapon:GetClass() ~= "weapon_physgun" or not client:KeyDown(IN_ATTACK)) then
        bind = string.lower(bind)
        if WepSelectInvert:GetBool() then invprev, invnext = invnext, invprev end
        if invprev and pressed then
            self.lastSlot = self.lastSlot - 1
            if self.lastSlot <= 0 then self.lastSlot = #client:GetWeapons() end
            self:OnSlotChanged()
            return true
        elseif invnext and pressed then
            self.lastSlot = self.lastSlot + 1
            if self.lastSlot > #client:GetWeapons() then self.lastSlot = 1 end
            self:OnSlotChanged()
            return true
        elseif string.find(bind, "+attack") and pressed then
            if CurTime() < self.deathTime then
                self.lifeTime = 0
                self.deathTime = 0
                for k, v in SortedPairs(client:GetWeapons()) do
                    if k == self.lastSlot then
                        RunConsoleCommand("lia_selectwep", v:GetClass())
                        return true
                    end
                end
            end
        elseif string.find(bind, "slot") then
            self.lastSlot = math.Clamp(tonumber(string.match(bind, "slot(%d)")) or 1, 1, #client:GetWeapons())
            self.lifeTime = CurTime() + LIFE_TIME
            self.deathTime = CurTime() + DEATH_TIME
            return true
        end
    end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if not client:getChar() then return end
    local x = ScrW() * 0.55
    for k, v in SortedPairs(client:GetWeapons()) do
        local y = (ScrH() * 0.4) + (k * 24)
        local color = Color(255, 255, 255, 255)
        if k == self.lastSlot then
            local schemaColor = lia.config.Color
            color.r = schemaColor.r
            color.g = schemaColor.g
            color.b = schemaColor.b
        end

        color.a = math.Clamp(255 - math.TimeFraction(self.lifeTime, self.deathTime, CurTime()) * 255, 0, 255)
        lia.util.drawText(string.upper(v:GetPrintName()), x, y, color, 0, 0, "liaItemBoldFont")
        if k == self.lastSlot and self.markup then
            surface.SetDrawColor(30, 30, 30, color.a * 0.95)
            surface.DrawRect(x + 118, ScrH() * 0.4 - 4, self.markup:GetWidth() + 20, self.markup:GetHeight() + 18)
            self.markup:Draw(x + 128, ScrH() * 0.4 + 24, 0, 1, color.a)
        end
    end
end

function MODULE:LoadFonts(_, genericFont)
    surface.CreateFont("Monofonto24", {
        font = "Monofonto",
        size = 24,
        weight = 500
    })

    surface.CreateFont("liaWeaponSelectorFont", {
        font = genericFont,
        size = 36,
        weight = 500
    })
end
