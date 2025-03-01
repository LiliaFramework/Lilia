lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        ATTRIBUTE = lia.attribs.list[niceName] or {}
        if MODULE then ATTRIBUTE.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
        ATTRIBUTE.desc = ATTRIBUTE.desc or "No description availalble."
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    function lia.attribs.setup(client)
        local character = client:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if v.OnSetup then v:OnSetup(client, character:getAttrib(k, 0)) end
            end
        end
    end
end

local function CreateFillableBarWithBackgroundAndLabel(parent, name, labelText, minVal, maxVal, dockMargin, valueFunc)
    local textFont = "liaSmallFont"
    local textColor = Color(255, 255, 255)
    local shadowColor = Color(30, 30, 30, 150)
    local entryContainer = vgui.Create("DPanel", parent)
    entryContainer:Dock(TOP)
    entryContainer:SetTall(30)
    entryContainer:DockMargin(8, dockMargin, 8, dockMargin)
    entryContainer.Paint = function(self, w, h)
        surface.SetDrawColor(shadowColor)
        surface.DrawRect(0, 0, w, h)
    end

    local label = vgui.Create("DLabel", entryContainer)
    label:SetFont(textFont)
    label:SetWide(100)
    label:Dock(LEFT)
    label:SetTextColor(textColor)
    label:SetText(labelText or name)
    label:SetContentAlignment(5)
    local bar = vgui.Create("DPanel", entryContainer)
    bar:Dock(FILL)
    bar.Paint = function(self, w, h)
        local currentValue = tonumber(valueFunc()) or 0
        local minValue = tonumber(minVal) or 0
        local maxValue = tonumber(maxVal) or 100
        local ratio = 0
        if maxValue - minValue > 0 then ratio = (currentValue - minValue) / (maxValue - minValue) end
        ratio = math.Clamp(ratio, 0, 1)
        local fillWidth = ratio * w
        surface.SetDrawColor(45, 45, 45, 255)
        surface.DrawRect(0, 0, fillWidth, h)
        draw.SimpleText(currentValue .. " / " .. maxValue, textFont, w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return bar
end

hook.Add("CreateMenuButtons", "AttributeMenuButtons", function(tabs)
    if hook.Run("CanPlayerViewAttributes") ~= false then
        tabs["Attributes"] = function(panel)
            panel:Clear()
            local container = vgui.Create("DPanel", panel)
            local containerWidth = panel:GetWide() * 0.5
            local containerHeight = panel:GetTall()
            container:SetSize(containerWidth, containerHeight)
            container:SetPos(panel:GetWide()*0.3, 303)
            container.Paint = function() end
            local scrollPanel = vgui.Create("DScrollPanel", container)
            scrollPanel:Dock(FILL)
            scrollPanel:DockMargin(8, 8, 8, 8)
            for _, attr in pairs(lia.attribs.list) do
                CreateFillableBarWithBackgroundAndLabel(scrollPanel, attr.name, attr.label or attr.name, attr.min or 0, attr.max or 100, 5, function()
                    if isfunction(attr.value) then return attr.value() end
                    return attr.value or 0
                end)
            end
        end
    end
end)