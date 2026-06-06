local MODULE = MODULE
net.Receive("liaSendLogsCategories", function()
    local categories = net.ReadTable()
    if not categories or #categories == 0 then
        chat.AddText(Color(255, 0, 0), L("failedRetrieveLogs"))
        return
    end

    local logsPanel = liaLogsPanel
    if not IsValid(logsPanel) then
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
            if IsValid(panel) and panel.liaLogsPanel then
                logsPanel = panel.liaLogsPanel
                liaLogsPanel = logsPanel
                break
            end
        end
    end

    if IsValid(logsPanel) then
        MODULE:CreateLogsUI(logsPanel, categories)
    else
        chat.AddText(Color(255, 100, 100), L("logsPanelError"))
    end
end)
