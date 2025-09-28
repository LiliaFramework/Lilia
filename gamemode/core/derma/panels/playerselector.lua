local PANEL = {}
function PANEL:Init()
    self:SetTitle(self.Title or L("selectPlayer"))
    self:SetSize(self.Width or 340, self.Height or 398)
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(false)
    self:DockPadding(0, 0, 0, 0)
    if self.ShowAnimation then self:ShowAnimation() end
    local contentPanel = vgui.Create("liaBasePanel", self)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(8, 0, 8, 8)
    self.scrollPanel = vgui.Create("liaScrollPanel", contentPanel)
    self.scrollPanel:Dock(FILL)
    self:PopulatePlayers()
    self.closeButton = self:Add("liaButton")
    self.closeButton:Dock(BOTTOM)
    self.closeButton:DockMargin(16, 8, 16, 12)
    self.closeButton:SetTall(36)
    self.closeButton:SetText(L("player_close"))
    self.closeButton.DoClick = function() self:Remove() end
    self.selectedPlayer = nil
    self.checkFunc = nil
end

function PANEL:PopulatePlayers()
    if not IsValid(self.scrollPanel) then return end
    self.scrollPanel:Clear()
    local CARD_HEIGHT = 44
    local AVATAR_SIZE = 32
    local AVATAR_X = 14
    local color_disconnect = Color(210, 65, 65)
    local color_bot = Color(70, 150, 220)
    local color_online = Color(120, 180, 70)
    for _, ply in player.Iterator() do
        self:CreatePlayerCard(ply, CARD_HEIGHT, AVATAR_SIZE, AVATAR_X, color_disconnect, color_bot, color_online)
    end
end

function PANEL:CreatePlayerCard(ply, CARD_HEIGHT, AVATAR_SIZE, AVATAR_X, color_disconnect, color_bot, color_online)
    local card = vgui.Create("liaButton", self.scrollPanel)
    card:Dock(TOP)
    card:DockMargin(0, 5, 0, 0)
    card:SetTall(CARD_HEIGHT)
    card:SetText('')
    card.hover_status = 0
    card.player = ply
    card.OnCursorEntered = function(self) self:SetCursor("hand") end
    card.OnCursorExited = function(self) self:SetCursor("arrow") end
    card.Think = function(self)
        local target = self:IsHovered() and 1 or 0
        self.hover_status = lia.util.approachExp(self.hover_status, target, 8, FrameTime())
    end

    card.DoClick = function()
        if IsValid(ply) and (not self.checkFunc or self.checkFunc(ply)) then
            surface.PlaySound("garrysmod/ui_click.wav")
            self.selectedPlayer = ply
            if self.OnAction then self:OnAction(ply) end
        end

        self:Remove()
    end

    card.pl_color = team.GetColor(ply:Team()) or color_online
    card.Paint = function(self, w, h)
        lia.rndx.Rect(0, 0, w, h):Rad(10):Color(lia.color.theme.background):Shape(lia.rndx.SHAPE_IOS):Draw()
        if self.hover_status > 0 then lia.rndx.Rect(0, 0, w, h):Rad(10):Color(Color(0, 0, 0, 40 * self.hover_status)):Shape(lia.rndx.SHAPE_IOS):Draw() end
        local infoX = AVATAR_X + AVATAR_SIZE + 10
        if not IsValid(ply) then
            draw.SimpleText(L("player_offline"), "Fated.18", infoX, h * 0.5, color_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            return
        end

        local char = ply:getChar()
        local name = hook.Run("GetDisplayedName", ply) or char and char.getName(char) or ply:Name()
        draw.SimpleText(name, "Fated.18", infoX, 6, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local group = ply:GetUserGroup() or "user"
        group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
        draw.SimpleText(group, "Fated.14", infoX, h - 6, Color("gray"), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(ply:Ping() .. " " .. L("player_ping"), "Fated.16", w - 20, h - 6, Color("gray"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        local statusColor
        if ply:IsBot() then
            statusColor = color_bot
        else
            statusColor = self.pl_color
        end

        lia.rndx.DrawCircle(w - 24, 14, 12, statusColor)
    end

    local avatarImg = vgui.Create("AvatarImage", card)
    avatarImg:SetSize(AVATAR_SIZE, AVATAR_SIZE)
    avatarImg:SetPos(AVATAR_X, (card:GetTall() - AVATAR_SIZE) * 0.5)
    avatarImg:SetSteamID(ply:SteamID64(), 64)
    avatarImg:SetMouseInputEnabled(false)
    avatarImg:SetKeyboardInputEnabled(false)
    avatarImg.PaintOver = function() end
    return card
end

function PANEL:RefreshPlayers()
    self:PopulatePlayers()
end

function PANEL:SetTitle(title)
    self.Title = title
    self:SetCenterTitle(title)
end

function PANEL:SetCheckFunc(func)
    self.checkFunc = func
end

function PANEL:GetSelectedPlayer()
    return self.selectedPlayer
end

function PANEL:Paint(_, _)
end

vgui.Register("liaPlayerSelector", PANEL, "liaFrame")
