local MODULE = MODULE
MODULE.fetchedContributors = MODULE.fetchedContributors or false
MODULE.avatarMaterials = MODULE.avatarMaterials or {}
MODULE.circleCache = MODULE.circleCache or {}
MODULE.CacheUrl = "https://raw.githubusercontent.com/LiliaFramework/Lilia/credits-cache"
MODULE.MaterialLocation = "lilia/credits-cache"
MODULE.contributorData = MODULE.contributorData or {
    {
        id = 33399712,
        name = "Samael",
        login = "Samael"
    },
}

local PANEL = {}
AccessorFunc(PANEL, "rowHeight", "RowHeight", FORCE_NUMBER)
DEFINE_BASECLASS("Panel")
function PANEL:Init()
    self.seperator = vgui.Create("Panel", self)
    self.seperator:Dock(TOP)
    self.seperator:SetTall(1)
    self.seperator.Paint = function(_, width, height)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-r"))
        surface.DrawTexturedRect(0, 0, width * 0.5, height)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-l"))
        surface.DrawTexturedRect(width * 0.5, 0, width * 0.5, height)
    end

    self.seperator:DockMargin(0, 4, 0, 4)
    self.sectionLabel = vgui.Create("DLabel", self)
    self.sectionLabel:Dock(TOP)
    self.sectionLabel:SetFont("liaBigCredits")
    self.sectionLabel:SetContentAlignment(4)
    self.sectionLabel:SetTextColor(color_white)
end

function PANEL:Clear()
    for _, v in ipairs(self:GetChildren()) do
        if v ~= self.seperator and v ~= self.sectionLabel then v:Remove() end
    end
end

function PANEL:SetText(text)
    self.sectionLabel:SetText(text)
    self.sectionLabel:SizeToContents()
end

function PANEL:Add(pnl)
    return BaseClass.Add(IsValid(self.currentRow) and self.currentRow or self:newRow(), pnl)
end

function PANEL:PerformLayout()
    local tall = 0
    for _, v in ipairs(self:GetChildren()) do
        local _, tM, _, bM = v:GetDockMargin()
        tall = tall + v:GetTall() + tM + bM
        v:InvalidateLayout()
    end

    self:SetTall(tall)
end

function PANEL:newRow()
    self.currentRow = vgui.Create("Panel", self)
    self.currentRow:Dock(TOP)
    self.currentRow:SetTall(self:GetRowHeight())
    self.currentRow.PerformLayout = function(this)
        local totalWidth = 0
        local newRow
        for k, v in ipairs(this:GetChildren()) do
            if k == 1 then v:DockMargin(0, 0, 0, 0) end
            local childWidth = v:GetWide() + v:GetDockMargin()
            totalWidth = totalWidth + childWidth
            if totalWidth > self:GetWide() and childWidth < self:GetWide() then
                newRow = newRow or self:newRow()
                v:SetParent(newRow)
            end
        end

        this:DockPadding(self:GetWide() * 0.5 - totalWidth * 0.5, 0, 0, 0)
    end
    return self.currentRow
end

vgui.Register("liaCreditsSpecialList", PANEL, "Panel")
PANEL = {}
function PANEL:Paint(w, h)
    surface.SetMaterial(lia.util.getMaterial("lilia/lilia.png"))
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(w * 0.5 - 75, h * 0.5 - 55, 160, 160)
end

vgui.Register("CreditsLogo", PANEL, "Panel")
PANEL = {}
function PANEL:Init()
    if lia.gui.creditsPanel then lia.gui.creditsPanel:Remove() end
    lia.gui.creditsPanel = self
    self.logo = self:Add("CreditsLogo")
    self.logo:SetTall(180)
    self.logo:Dock(TOP)
    self.Label = self:Add("DLabel")
    self.Label:SetFont("liaBigCredits")
    self.Label:SetText("Lilia")
    self.Label:SetContentAlignment(5)
    self.Label:SizeToContents()
    self.Label:Dock(TOP)
    self.Label:SetTextColor(color_white)
    self.repoLabel = self:Add("DLabel")
    self.repoLabel:SetFont("liaSmallCredits")
    self.repoLabel:SetText("https://github.com/LiliaFramework")
    self.repoLabel:SetMouseInputEnabled(true)
    self.repoLabel:SetCursor("hand")
    self.repoLabel:SetContentAlignment(5)
    self.repoLabel:SizeToContents()
    self.repoLabel:Dock(TOP)
    self.repoLabel:SetTextColor(color_white)
    self.repoLabel.DoClick = function() gui.OpenURL("https://github.com/LiliaFramework") end
    if table.Count(MODULE.LiliaCreator) > 0 then
        self.creatorList = self:Add("liaCreditsSpecialList")
        self.creatorList:Dock(TOP)
        self.creatorList:SetText("Creators")
        self.creatorList:SetRowHeight(ScreenScale(32))
        self.creatorList:DockMargin(0, 0, 0, 4)
    end

    if table.Count(MODULE.LiliaMaintainer) > 0 then
        self.maintainerList = self:Add("liaCreditsSpecialList")
        self.maintainerList:Dock(TOP)
        self.maintainerList:SetText("Maintainers")
        self.maintainerList:SetRowHeight(ScreenScale(32))
        self.maintainerList:DockMargin(0, 0, 0, 4)
    end

    local seperator = self:Add("Panel")
    seperator:Dock(TOP)
    seperator:SetTall(1)
    seperator.Paint = function(_, width, height)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-r"))
        surface.DrawTexturedRect(0, 0, width * 0.5, height)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-l"))
        surface.DrawTexturedRect(width * 0.5, 0, width * 0.5, height)
    end

    seperator:DockMargin(0, 4, 0, 4)
    self.contribLabel = self:Add("DLabel")
    self.contribLabel:SetFont("liaBigCredits")
    self.contribLabel:SetText("Contributors")
    self.contribLabel:SetContentAlignment(4)
    self.contribLabel:SizeToContents()
    self.contribLabel:Dock(TOP)
    self.contribLabel:SetTextColor(color_white)
    self.contribList = self:Add("DIconLayout")
    self.contribList:Dock(TOP)
    self.contribList:SetSpaceX(16)
    self.contribList:SetSpaceY(16)
    if not MODULE.fetchedContributors then
        HTTP({
            url = MODULE.CacheUrl .. "/contributors.json",
            method = "GET",
            success = function(_, body)
                MODULE.contributorData = {}
                MODULE.fetchedContributors = true
                local contributors = util.JSONToTable(body)
                for _, data in ipairs(contributors or {}) do
                    if istable(data) and data.id then table.insert(MODULE.contributorData, data) end
                end

                if IsValid(self) then self:rebuildContributors() end
            end,
            failed = function() if IsValid(self) then self:rebuildContributors() end end
        })
    else
        self:rebuildContributors()
    end
end

function PANEL:rebuildContributors()
    if IsValid(self.creatorList) then self.creatorList:Clear() end
    if IsValid(self.maintainerList) then self.maintainerList:Clear() end
    self.contribList:Clear()
    self:loadContributor(1, true)
end

local drawCircle = function(x, y, r, s)
    local c = MODULE.circleCache
    local cir = {}
    if c[x] and c[x][y] and c[x][y][r][s] and c[x][y][r][s] then
        cir = c[x][y][r][s]
    else
        table.insert(cir, {
            x = x,
            y = y,
            u = 0.5,
            v = 0.5
        })

        for i = 0, s do
            local a = math.rad((i / s) * -360)
            table.insert(cir, {
                x = x + math.sin(a) * r,
                y = y + math.cos(a) * r,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            })
        end

        local a = math.rad(0)
        table.insert(cir, {
            x = x + math.sin(a) * r,
            y = y + math.cos(a) * r,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })

        c[x] = c[x] or {}
        c[x][y] = c[x][y] or {}
        c[x][y][r] = c[x][y][r] or {}
        c[x][y][r][s] = cir
        MODULE.circleCache = c
    end

    surface.DrawPoly(cir)
end

function PANEL:loadContributor(contributor, bLoadNextChunk)
    local contributorData = MODULE.contributorData[contributor]
    if contributorData then
        local isCreator = MODULE.LiliaCreator[contributorData.id]
        local isMaintainer = MODULE.LiliaMaintainer[contributorData.id]
        local container = vgui.Create("Panel")
        if isCreator then
            self.creatorList:Add(container)
        elseif isMaintainer then
            self.maintainerList:Add(container)
        else
            self.contribList:Add(container)
        end

        container:Dock((isCreator or isMaintainer) and LEFT or NODOCK)
        container:DockMargin(unpack((isCreator or isMaintainer) and {16, 0, 0, 0} or {0, 0, 0, 0}))
        container:DockPadding(8, 8, 8, 8)
        container.highlightAlpha = 0
        container.Paint = function(this, width, height)
            if this:IsHovered() then
                this.highlightAlpha = Lerp(FrameTime() * 16, this.highlightAlpha, 128)
            else
                this.highlightAlpha = Lerp(FrameTime() * 16, this.highlightAlpha, 0)
            end

            surface.SetDrawColor(ColorAlpha(lia.config.Color, this.highlightAlpha * 0.5))
            surface.SetMaterial((isCreator or isMaintainer) and lia.util.getMaterial("vgui/gradient-l") or lia.util.getMaterial("vgui/gradient-d"))
            surface.DrawTexturedRect(0, 0, width, height)
            surface.SetDrawColor(ColorAlpha(lia.config.Color, this.highlightAlpha))
            if isCreator or isMaintainer then
                surface.DrawRect(0, 0, 1, height)
            else
                surface.DrawRect(0, height - 1, width, 1)
            end
        end

        container.OnMousePressed = function(_, keyCode) if keyCode == 107 then gui.OpenURL("https://github.com/" .. contributorData.login) end end
        container:SetCursor("hand")
        container:SetTooltip("https://github.com/" .. contributorData.login)
        local avatar = container:Add("Panel")
        avatar:SetMouseInputEnabled(false)
        avatar:Dock((isCreator or isMaintainer) and LEFT or FILL)
        avatar:DockMargin(unpack((isCreator or isMaintainer) and {0, 0, 8, 0} or {0, 0, 0, 8}))
        avatar:SetWide(isCreator and ScreenScale(32) - 8 * 2 or isMaintainer and ScreenScale(32) - 8 * 2 or 0)
        avatar.Paint = function(this, width, height)
            if this.material then
                surface.SetMaterial(this.material)
                surface.SetDrawColor(255, 255, 255, 255)
                drawCircle(width * 0.5, height * 0.5, width * 0.5, 64)
            end
        end

        if bLoadNextChunk then
            avatar.OnFinishGettingMaterial = function()
                local toLoad = 7
                for i = 1, toLoad do
                    if contributor + i > #MODULE.contributorData then return end
                    self:loadContributor(contributor + i, i == toLoad)
                end
            end
        end

        if not MODULE.avatarMaterials[contributor] then
            HTTP({
                url = MODULE.CacheUrl .. "/" .. contributorData.id,
                method = "GET",
                success = function(_, body)
                    file.CreateDir(MODULE.MaterialLocation)
                    file.Write(MODULE.MaterialLocation .. "/" .. tostring(contributorData.id) .. ".png", body)
                    MODULE.avatarMaterials[contributor] = Material("data/" .. MODULE.MaterialLocation .. "/" .. tostring(contributorData.id) .. ".png", "mips smooth")
                    if IsValid(avatar) then
                        avatar.material = MODULE.avatarMaterials[contributor]
                        if avatar.OnFinishGettingMaterial then avatar:OnFinishGettingMaterial() end
                    end
                end
            })
        else
            avatar.material = MODULE.avatarMaterials[contributor]
            if avatar.OnFinishGettingMaterial then avatar:OnFinishGettingMaterial() end
        end

        local name = container:Add("DLabel")
        name:SetMouseInputEnabled(false)
        name:SetText(MODULE.GithubNameOverrides[contributorData.id] or contributorData.name)
        name:SetContentAlignment(5)
        name:Dock((isCreator or isMaintainer) and FILL or BOTTOM)
        name:SetFont((isCreator or isMaintainer) and "liaBigCredits" or "liaSmallCredits")
        name:SizeToContents()
        name:SetTextColor(color_white)
        container:SetSize(isCreator and name:GetWide() + ScreenScale(32) + 8 or isMaintainer and name:GetWide() + ScreenScale(32) + 8 or ScreenScale(32), name:GetTall() + ScreenScale(32) + 8)
    end
end

vgui.Register("liaCreditsList", PANEL, "Panel")