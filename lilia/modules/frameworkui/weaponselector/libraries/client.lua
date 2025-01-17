local pi = math.pi
MODULE.index = MODULE.index or 1
MODULE.deltaIndex = MODULE.deltaIndex or MODULE.index
MODULE.infoAlpha = MODULE.infoAlpha or 0
MODULE.alpha = MODULE.alpha or 0
MODULE.alphaDelta = MODULE.alphaDelta or MODULE.alpha
MODULE.fadeTime = MODULE.fadeTime or 0
local IsValid, tonumber, FrameTime, Lerp, ScrW, ScrH, CurTime, ipairs = IsValid, tonumber, FrameTime, Lerp, ScrW, ScrH, CurTime, ipairs
local RunConsoleCommand, LocalPlayer, math, color_white, surface = RunConsoleCommand, LocalPlayer, math, color_white, surface
local CVAR_WEPSELECT_INVERT = CreateClientConVar("wepselect_invert", 0, true)
function MODULE:getWeaponFromIndex(i)
    local index = 1
    for k, v in pairs(LocalPlayer():GetWeapons()) do
        if index == i then return v end
        index = index + 1
    end
    return NULL
end

function MODULE:HUDPaint()
    local frameTime = FrameTime()
    local fraction = self.alphaDelta
    if fraction <= 0.01 and self.alpha == 0 then
        self.alphaDelta = 0
        return
    else
        self.alphaDelta = Lerp(frameTime * 10, self.alphaDelta, self.alpha)
    end

    local shiftX = ScrW() * .02
    local client = LocalPlayer()
    local weapons = client:GetWeapons()
    local x, y = ScrW() * 0.05, ScrH() * 0.5
    local spacing = math.pi * 0.85
    local radius = 240 * self.alphaDelta
    self.deltaIndex = Lerp(frameTime * 12, self.deltaIndex, self.index)
    local index = self.deltaIndex
    local realIndex = 1
    for _, v in pairs(weapons) do
        local theta = (realIndex - index) * 0.1
        local color = ColorAlpha(realIndex == self.index and lia.config.Color or color_white, (255 - math.abs(theta * 3) * 255) * fraction)
        local lastY = 0
        if self.markup and (realIndex == 1 or realIndex < self.index) then
            local w, h = self.markup:Size()
            lastY = h * fraction
            if realIndex == self.index - 1 or realIndex == 1 then
                self.infoAlpha = Lerp(frameTime * 5, self.infoAlpha, 255)
                self.markup:Draw(x + 6 + shiftX, y + 30, 0, 0, self.infoAlpha * fraction)
            end

            if self.index == 1 then lastY = 0 end
        end

        surface.SetFont("liaSubTitleFont")
        local name = hook.Run("GetWeaponName", v) or v:GetPrintName():upper()
        local tx, ty = surface.GetTextSize(name)
        local scale = 1 - math.abs(theta * 2)
        local matrix = Matrix()
        matrix:Translate(Vector(shiftX + x + math.cos(theta * spacing + pi) * radius + radius, y + lastY + math.sin(theta * spacing + pi) * radius - ty / 2, 1))
        matrix:Scale(Vector(1, 1, 0) * scale)
        cam.PushModelMatrix(matrix)
        lia.util.drawText(name, 2, ty / 2, color, 0, 1, "liaSubTitleFont")
        cam.PopModelMatrix()
        realIndex = realIndex + 1
    end

    if self.fadeTime < CurTime() and self.alpha > 0 then self.alpha = 0 end
end

function MODULE:onIndexChanged()
    self.alpha = 1
    self.fadeTime = CurTime() + 5
    local client = LocalPlayer()
    local weapon
    local index = 1
    for k, v in pairs(client:GetWeapons()) do
        if index == self.index then
            weapon = v
            break
        end

        index = index + 1
    end

    self.markup = nil
    self.infoAlpha = 0
    if IsValid(weapon) then
        local text = ""
        for k, v in ipairs({"Author", "Contact", "Purpose", "Instructions"}) do
            if weapon[v] and weapon[v]:find("%S") then
                local color = lia.config.Color
                text = text .. "<font=liaItemBoldFont><color=" .. color.r .. "," .. color.g .. "," .. color.b .. ">" .. L(v) .. "</font></color>\n" .. weapon[v] .. "\n"
            end
        end

        if text ~= "" then self.markup = markup.Parse("<font=liaItemDescFont>" .. text, ScrW() * 0.3) end
        local source, pitch = hook.Run("WeaponCycleSound") or "common/talk.wav"
        client:EmitSound(source or "common/talk.wav", 45, pitch or 180)
    end
end

function MODULE:SetupQuickMenu(menu)
    menu:addCategory(self.name)
    menu:addCheck(L"invertWepSelectScroll", function(panel, state)
        if state then
            RunConsoleCommand("wepselect_invert", "1")
        else
            RunConsoleCommand("wepselect_invert", "0")
        end
    end, CVAR_WEPSELECT_INVERT:GetBool(), "Miscellaneous")

    menu:addSpacer()
end

function MODULE:PlayerBindPress(client, bind, pressed)
    local weapon = client:GetActiveWeapon()
    local lPly = LocalPlayer()
    if client:InVehicle() then return end
    if IsValid(weapon) and weapon:GetClass() == "weapon_physgun" and client:KeyDown(IN_ATTACK) then return end
    if hook.Run("CanPlayerChooseWeapon") == false then return end
    if not pressed then return end
    bind = bind:lower()
    local total = table.Count(client:GetWeapons())
    local invprev, invnext = isnumber(bind:find("invprev")), isnumber(bind:find("invnext"))
    if CVAR_WEPSELECT_INVERT:GetBool() then invprev, invnext = invnext, invprev end
    if invprev then
        self.index = self.index - 1
        if self.index < 1 then self.index = total end
        self:onIndexChanged()
        return true
    elseif invnext then
        self.index = self.index + 1
        if self.index > total then self.index = 1 end
        self:onIndexChanged()
        return true
    elseif bind:find("slot") then
        self.index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, total)
        self:onIndexChanged()
        return true
    elseif bind:find("attack") and self.alpha > 0 then
        local weapon = self:getWeaponFromIndex(self.index)
        if not IsValid(weapon) then
            self.alpha = 0
            self.infoAlpha = 0
            return
        end

        local source, pitch = hook.Run("WeaponSelectSound", weapon) or "common/talk.wav"
        lPly:EmitSound(source, 45, pitch or 200)
        lPly:SelectWeapon(weapon:GetClass())
        self.alpha = 0
        self.infoAlpha = 0
        return true
    end
end

local meta = FindMetaTable("Player")
function meta:SelectWeapon(class)
    if not self:HasWeapon(class) then return end
    self.doWeaponSwitch = self:GetWeapon(class)
end

function MODULE:StartCommand(client, cmd)
    if not IsValid(client.doWeaponSwitch) then return end
    cmd:SelectWeapon(client.doWeaponSwitch)
    if client:GetActiveWeapon() == client.doWeaponSwitch then client.doWeaponSwitch = nil end
end