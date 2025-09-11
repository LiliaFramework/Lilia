local PANEL = {}
function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
    self:SetZPos(32767)
    -- Background
    self.background = self:Add("DPanel")
    self.background:SetSize(ScrW(), ScrH())
    self.background:SetPos(0, 0)
    self.background.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 240)) end
    -- Main container
    self.container = self:Add("DPanel")
    self.container:SetSize(600, 300)
    self.container:SetPos((ScrW() - 600) / 2, (ScrH() - 300) / 2)
    self.container.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 255))
        draw.RoundedBox(8, 4, 4, w - 8, h - 8, Color(20, 20, 20, 255))
    end

    -- Title
    self.titleLabel = self.container:Add("DLabel")
    self.titleLabel:SetFont("liaBigFont")
    self.titleLabel:SetText("Server Failed To Load")
    self.titleLabel:SizeToContents()
    self.titleLabel:SetPos((600 - self.titleLabel:GetWide()) / 2, 30)
    self.titleLabel:SetTextColor(Color(255, 100, 100))
    -- Error message
    self.messageLabel = self.container:Add("DLabel")
    self.messageLabel:SetFont("liaMediumFont")
    self.messageLabel:SetText("The server encountered critical errors during startup.\nPlease refer to the server console for detailed error information.")
    self.messageLabel:SetSize(550, 80)
    self.messageLabel:SetPos(25, 80)
    self.messageLabel:SetWrap(true)
    self.messageLabel:SetTextColor(Color(255, 255, 255))
    self.messageLabel:SetContentAlignment(5)
    -- Failure reason (if available)
    self.reasonLabel = self.container:Add("DLabel")
    self.reasonLabel:SetFont("liaSmallFont")
    self.reasonLabel:SetText("")
    self.reasonLabel:SetSize(550, 60)
    self.reasonLabel:SetPos(25, 170)
    self.reasonLabel:SetWrap(true)
    self.reasonLabel:SetTextColor(Color(200, 200, 200))
    self.reasonLabel:SetContentAlignment(5)
    -- Console hint
    self.hintLabel = self.container:Add("DLabel")
    self.hintLabel:SetFont("liaSmallFont")
    self.hintLabel:SetText("Press F1 for console or check server logs for more details")
    self.hintLabel:SetSize(550, 30)
    self.hintLabel:SetPos(25, 240)
    self.hintLabel:SetWrap(true)
    self.hintLabel:SetTextColor(Color(150, 150, 150))
    self.hintLabel:SetContentAlignment(5)
    -- Retry button (in case it's a temporary issue)
    self.retryButton = self.container:Add("DButton")
    self.retryButton:SetSize(100, 30)
    self.retryButton:SetPos((600 - 100) / 2, 260)
    self.retryButton:SetText("Retry")
    self.retryButton:SetFont("liaSmallFont")
    self.retryButton.DoClick = function() RunConsoleCommand("retry") end
    self.retryButton.Paint = function(panel, w, h)
        local color = panel:IsHovered() and Color(100, 100, 100) or Color(70, 70, 70)
        draw.RoundedBox(4, 0, 0, w, h, color)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(50, 50, 50))
    end
end

function PANEL:SetFailureInfo(reason, details)
    if reason then self.reasonLabel:SetText("Error: " .. reason .. "\n" .. (details or "")) end
end

function PANEL:AddError(errorMessage, line, file)
    -- Create or get error list
    if not self.errorList then
        self.errorList = {}
        self.errorCount = 0
    end

    -- Add error to list
    self.errorCount = self.errorCount + 1
    table.insert(self.errorList, {
        message = errorMessage,
        line = line,
        file = file
    })

    -- Update display
    self:UpdateErrorDisplay()
end

function PANEL:UpdateErrorDisplay()
    if not self.errorList or #self.errorList == 0 then return end
    local errorText = "Recent Errors:\n"
    for i, err in ipairs(self.errorList) do
        errorText = errorText .. string.format("%d. %s | %s | %s\n", i, err.message, err.line or "N/A", err.file or "Unknown")
    end

    -- Create or update error display label
    if not IsValid(self.errorDisplayLabel) then
        self.errorDisplayLabel = self.container:Add("DLabel")
        self.errorDisplayLabel:SetFont("liaSmallFont")
        self.errorDisplayLabel:SetSize(550, 200)
        self.errorDisplayLabel:SetPos(25, 300)
        self.errorDisplayLabel:SetWrap(true)
        self.errorDisplayLabel:SetTextColor(Color(255, 200, 200))
        self.errorDisplayLabel:SetContentAlignment(7) -- Top-left alignment
        -- Adjust container size to accommodate errors
        self.container:SetSize(600, 520)
        self.container:SetPos((ScrW() - 600) / 2, (ScrH() - 520) / 2)
    end

    self.errorDisplayLabel:SetText(errorText)
end

function PANEL:Paint(w, h)
    -- Draw a subtle vignette effect
    local centerX, centerY = w / 2, h / 2
    for i = 1, 20 do
        local alpha = 255 - (i * 10)
        local size = i * 50
        draw.RoundedBox(0, centerX - size / 2, centerY - size / 2, size, size, Color(0, 0, 0, alpha))
    end
end

vgui.Register("liaLoadingFailure", PANEL, "DPanel")