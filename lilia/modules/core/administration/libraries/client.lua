function MODULE:ShowPlayerOptions(target, options)
    local client = LocalPlayer()
    if (client:hasPrivilege("Staff Permissions - Can Access Scoreboard Info Out Of Staff") or client:hasPrivilege("Staff Permissions - Can Access Scoreboard Admin Options") and client:isStaffOnDuty()) and IsValid(target) then
        local orderedOptions = {
            {
                name = "Name: " .. target:Name() .. " (copy)",
                image = "icon16/page_copy.png",
                func = function()
                    client:ChatPrint("Copied " .. target:Name() .. " to Clipboard!")
                    SetClipboardText(target:Name())
                end
            },
            {
                name = "CharID: " .. (target:getChar() and target:getChar():getID() or "N/A") .. " (copy)",
                image = "icon16/page_copy.png",
                func = function()
                    if target:getChar() then
                        client:ChatPrint("Copied CharID: " .. target:getChar():getID() .. " to Clipboard!")
                        SetClipboardText(target:getChar():getID())
                    end
                end
            },
            {
                name = "SteamID: " .. target:SteamID() .. " (copy)",
                image = "icon16/page_copy.png",
                func = function()
                    client:ChatPrint("Copied SteamID: " .. target:SteamID() .. " to Clipboard!")
                    SetClipboardText(target:SteamID())
                end
            },
            {
                name = "SteamID64: " .. target:SteamID64() .. " (copy)",
                image = "icon16/page_copy.png",
                func = function()
                    client:ChatPrint("Copied SteamID64: " .. target:SteamID64() .. " to Clipboard!")
                    SetClipboardText(target:SteamID64())
                end
            },
            {
                name = "Blind",
                image = "icon16/eye.png",
                func = function() RunConsoleCommand("say", "!blind " .. target:SteamID()) end
            },
            {
                name = "Freeze",
                image = "icon16/lock.png",
                func = function() RunConsoleCommand("say", "!freeze " .. target:SteamID()) end
            },
            {
                name = "Gag",
                image = "icon16/sound_mute.png",
                func = function() RunConsoleCommand("say", "!gag " .. target:SteamID()) end
            },
            {
                name = "Ignite",
                image = "icon16/fire.png",
                func = function() RunConsoleCommand("say", "!ignite " .. target:SteamID()) end
            },
            {
                name = "Jail",
                image = "icon16/lock.png",
                func = function() RunConsoleCommand("say", "!jail " .. target:SteamID()) end
            },
            {
                name = "Mute",
                image = "icon16/sound_delete.png",
                func = function() RunConsoleCommand("say", "!mute " .. target:SteamID()) end
            },
            {
                name = "Slay",
                image = "icon16/bomb.png",
                func = function() RunConsoleCommand("say", "!slay " .. target:SteamID()) end
            },
            {
                name = "Unblind",
                image = "icon16/eye.png",
                func = function() RunConsoleCommand("say", "!unblind " .. target:SteamID()) end
            },
            {
                name = "Ungag",
                image = "icon16/sound_low.png",
                func = function() RunConsoleCommand("say", "!ungag " .. target:SteamID()) end
            },
            {
                name = "Unfreeze",
                image = "icon16/accept.png",
                func = function() RunConsoleCommand("say", "!unfreeze " .. target:SteamID()) end
            },
            {
                name = "Unmute",
                image = "icon16/sound_add.png",
                func = function() RunConsoleCommand("say", "!unmute " .. target:SteamID()) end
            },
            {
                name = "Bring",
                image = "icon16/arrow_down.png",
                func = function() RunConsoleCommand("say", "!bring " .. target:SteamID()) end
            },
            {
                name = "Goto",
                image = "icon16/arrow_right.png",
                func = function() RunConsoleCommand("say", "!goto " .. target:SteamID()) end
            },
            {
                name = "Respawn",
                image = "icon16/arrow_refresh.png",
                func = function() RunConsoleCommand("say", "!respawn " .. target:SteamID()) end
            },
            {
                name = "Return",
                image = "icon16/arrow_redo.png",
                func = function() RunConsoleCommand("say", "!return " .. target:SteamID()) end
            }
        }

        for _, option in ipairs(orderedOptions) do
            table.insert(options, option)
        end
    end
end

function MODULE:LoadFonts(font)
    surface.CreateFont("ConfigFont", {
        font = font,
        size = 26,
        weight = 500,
        extended = true,
        antialias = true
    })

    surface.CreateFont("MediumConfigFont", {
        font = font,
        size = 30,
        weight = 1000,
        extended = true,
        antialias = true
    })

    surface.CreateFont("SmallConfigFont", {
        font = font,
        size = math.max(ScreenScale(8), 20),
        weight = 500,
        extended = true,
        antialias = true
    })

    surface.CreateFont("ConfigFontBold", {
        font = font,
        size = 26,
        weight = 1000,
        extended = true,
        antialias = true
    })

    surface.CreateFont("ConfigFontLarge", {
        font = font,
        size = 36,
        weight = 700,
        extended = true,
        antialias = true
    })

    surface.CreateFont("DescriptionFontLarge", {
        font = font,
        size = 24,
        weight = 500,
        extended = true,
        antialias = true
    })
end

local ConfigFormatting = {
    Int = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local slider = panel:Add("DNumSlider")
        slider:Dock(FILL)
        slider:DockMargin(10, 0, 10, 0)
        slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
        slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
        slider:SetDecimals(0)
        slider:SetValue(lia.config.get(key, config.value))
        slider:SetText("")
        slider.PerformLayout = function()
            slider.Label:SetWide(0)
            slider.TextArea:SetWide(50)
        end

        slider.OnValueChanged = function(_, newValue)
            local timerName = "ConfigChange_" .. key .. "_" .. os.time()
            timer.Create(timerName, 0.5, 1, function() netstream.Start("cfgSet", key, name, math.floor(newValue)) end)
        end
        return container
    end,
    Float = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local slider = panel:Add("DNumSlider")
        slider:Dock(FILL)
        slider:DockMargin(10, 0, 10, 0)
        slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
        slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
        slider:SetDecimals(2)
        slider:SetValue(lia.config.get(key, config.value))
        slider:SetText("")
        slider.PerformLayout = function()
            slider.Label:SetWide(0)
            slider.TextArea:SetWide(50)
        end

        slider.OnValueChanged = function(_, newValue)
            local timerName = "ConfigChange_" .. key .. "_" .. os.time()
            timer.Create(timerName, 0.5, 1, function() netstream.Start("cfgSet", key, name, tonumber(newValue)) end)
        end
        return container
    end,
    Generic = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function() end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local entry = panel:Add("DTextEntry")
        entry:Dock(TOP)
        entry:SetTall(60)
        entry:DockMargin(300, 10, 300, 0)
        entry:SetText(tostring(lia.config.get(key, config.value)))
        entry:SetFont("ConfigFontLarge")
        entry:SetTextColor(Color(255, 255, 255))
        entry.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
            self:DrawTextEntryText(Color(255, 255, 255), Color(255, 255, 255), Color(255, 255, 255))
        end

        entry.OnEnter = function()
            local newValue = entry:GetText()
            local timerName = "ConfigChange_" .. key .. "_" .. os.time()
            timer.Create(timerName, 0.5, 1, function() netstream.Start("cfgSet", key, name, newValue) end)
        end
        return container
    end,
    Boolean = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local button = panel:Add("DButton")
        button:Dock(TOP)
        button:SetTall(100)
        button:DockMargin(100, 10, 100, 0)
        button:SetText("")
        button:SetCursor("hand")
        local checkIcon = "✓"
        local uncheckIcon = "✗"
        button.Paint = function(_, w, h)
            local isChecked = lia.config.get(key, config.value)
            surface.SetDrawColor(isChecked and Color(0, 150, 0) or Color(150, 0, 0))
            surface.DrawRect(w / 4, -25, w / 2, h)
            draw.SimpleText(isChecked and checkIcon or uncheckIcon, "liaIconsHugeNew", w / 2, h / 2 - 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        button.DoClick = function()
            local newValue = not lia.config.get(key, config.value)
            local timerName = "ConfigChange_" .. key .. "_" .. os.time()
            timer.Create(timerName, 0.5, 1, function() netstream.Start("cfgSet", key, name, newValue) end)
        end
        return container
    end,
    Color = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local button = panel:Add("DButton")
        button:Dock(FILL)
        button:DockMargin(10, 0, 10, 0)
        button:SetText("")
        button:SetCursor("hand")
        button.Paint = function(_, w, h)
            local colorValue = lia.config.get(key, config.value)
            surface.SetDrawColor(colorValue)
            surface.DrawRect(10, h / 2 - 15, w - 20, 30)
            draw.RoundedBox(2, 10, h / 2 - 15, w - 20, 30, Color(255, 255, 255, 50))
        end

        button.DoClick = function()
            if IsValid(button.picker) then button.picker:Remove() end
            local pickerFrame = vgui.Create("DFrame")
            pickerFrame:SetSize(300, 400)
            pickerFrame:SetTitle("Choose Color")
            pickerFrame:Center()
            pickerFrame:MakePopup()
            local colorMixer = pickerFrame:Add("DColorMixer")
            colorMixer:Dock(FILL)
            colorMixer:SetPalette(true)
            colorMixer:SetAlphaBar(true)
            colorMixer:SetWangs(true)
            colorMixer:SetColor(lia.config.get(key, config.value))
            local confirm = pickerFrame:Add("DButton")
            confirm:Dock(BOTTOM)
            confirm:SetTall(40)
            confirm:SetText("Apply")
            confirm:SetTextColor(color_white)
            confirm:SetFont("ConfigFontLarge")
            confirm:SetBackgroundColor(Color(0, 150, 0))
            confirm:DockMargin(10, 10, 10, 10)
            confirm.DoClick = function()
                local newColor = colorMixer:GetColor()
                local timerName = "ConfigChange_" .. key .. "_" .. os.time()
                timer.Create(timerName, 0.5, 1, function() netstream.Start("cfgSet", key, name, newColor) end)
                pickerFrame:Remove()
            end

            colorMixer.ValueChanged = function(_, value) pickerFrame.curColor = value end
            button.picker = pickerFrame
        end
        return container
    end,
    Table = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local comboBox = panel:Add("DComboBox")
        comboBox:Dock(TOP)
        comboBox:SetTall(60)
        comboBox:DockMargin(300, 10, 300, 0)
        comboBox:SetValue(tostring(lia.config.get(key, config.value)))
        comboBox:SetFont("ConfigFontLarge")
        comboBox:SetTextColor(Color(255, 255, 255))
        comboBox.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
            self:DrawTextEntryText(Color(255, 255, 255), Color(255, 255, 255), Color(255, 255, 255))
        end

        local options = lia.config.get(key .. "_options", config.data and config.data.options or {})
        for _, option in ipairs(options) do
            comboBox:AddChoice(option)
        end

        comboBox.OnSelect = function(_, _, value)
            local timerName = "ConfigChange_" .. key .. "_" .. os.time()
            timer.Create(timerName, 0.5, 1, function() netstream.Start("cfgSet", key, name, value) end)
        end
        return container
    end
}

local OptionFormatting = {
    Int = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local slider = panel:Add("DNumSlider")
        slider:Dock(FILL)
        slider:DockMargin(10, 0, 10, 0)
        slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
        slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
        slider:SetDecimals(0)
        slider:SetValue(lia.option.get(key, config.value))
        slider.PerformLayout = function()
            slider.Label:SetWide(100)
            slider.TextArea:SetWide(50)
        end

        slider.OnValueChanged = function(_, newValue) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.floor(newValue)) end) end
        return container
    end,
    Float = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local slider = panel:Add("DNumSlider")
        slider:Dock(FILL)
        slider:DockMargin(10, 0, 10, 0)
        slider:SetMin(lia.config.get(key .. "_min", config.data and config.data.min or 0))
        slider:SetMax(lia.config.get(key .. "_max", config.data and config.data.max or 1))
        slider:SetDecimals(2)
        slider:SetValue(lia.option.get(key, config.value))
        slider.PerformLayout = function()
            slider.Label:SetWide(100)
            slider.TextArea:SetWide(50)
        end

        slider.OnValueChanged = function(_, newValue) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.Round(newValue, 2)) end) end
        return container
    end,
    Generic = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function() end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local entry = panel:Add("DTextEntry")
        entry:Dock(TOP)
        entry:SetTall(60)
        entry:DockMargin(300, 10, 300, 0)
        entry:SetText(tostring(lia.option.get(key, config.value)))
        entry:SetFont("ConfigFontLarge")
        entry:SetTextColor(Color(255, 255, 255))
        entry.OnEnter = function(btn)
            local newValue = btn:GetText()
            lia.option.set(key, newValue)
        end
        return container
    end,
    Boolean = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local button = panel:Add("DButton")
        button:Dock(TOP)
        button:SetTall(100)
        button:DockMargin(100, 10, 100, 0)
        button:SetText("")
        button.Paint = function(_, w, h)
            local check = getIcon("0xe880", true)
            local uncheck = getIcon("0xf096", true)
            local icon = lia.option.get(key, config.value) and check or uncheck
            lia.util.drawText(icon, w / 2, h / 2 - 10, color_white, 1, 1, "liaIconsHugeNew")
        end

        button.DoClick = function() lia.option.set(key, not lia.option.get(key, config.value)) end
        return container
    end,
    Color = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(220)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local button = panel:Add("DButton")
        button:Dock(FILL)
        button:DockMargin(10, 0, 10, 0)
        button:SetText("")
        button.Paint = function(_, w, h)
            surface.SetDrawColor(lia.option.get(key, config.value))
            surface.DrawRect(w - 925, h / 2 - 27, 500, 54)
        end

        button.DoClick = function(this)
            local pickerFrame = this:Add("DFrame")
            pickerFrame:SetSize(ScrW() * 0.15, ScrH() * 0.2)
            pickerFrame:SetPos(gui.MouseX(), gui.MouseY())
            pickerFrame:MakePopup()
            if IsValid(button.picker) then button.picker:Remove() end
            button.picker = pickerFrame
            local Mixer = pickerFrame:Add("DColorMixer")
            Mixer:Dock(FILL)
            Mixer:SetPalette(true)
            Mixer:SetAlphaBar(true)
            Mixer:SetWangs(true)
            Mixer:SetColor(lia.option.get(key, config.value))
            pickerFrame.curColor = lia.option.get(key, config.value)
            local confirm = pickerFrame:Add("DButton")
            confirm:Dock(BOTTOM)
            confirm:SetText("Apply")
            confirm:SetTextColor(color_white)
            confirm.DoClick = function()
                timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, pickerFrame.curColor) end)
                pickerFrame:Remove()
            end

            Mixer.ValueChanged = function(_, value) pickerFrame.curColor = value end
        end
        return container
    end,
    Table = function(key, name, config, parent)
        local container = vgui.Create("DPanel", parent)
        container:SetTall(300)
        container:Dock(TOP)
        container:DockMargin(0, 60, 0, 10)
        container.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
        local panel = container:Add("DPanel")
        panel:Dock(FILL)
        panel.Paint = nil
        local label = panel:Add("DLabel")
        label:Dock(TOP)
        label:SetTall(45)
        label:SetText(name)
        label:SetFont("ConfigFontLarge")
        label:SetContentAlignment(5)
        label:SetTextColor(Color(255, 255, 255))
        label:DockMargin(0, 20, 0, 0)
        local description = panel:Add("DLabel")
        description:Dock(TOP)
        description:SetTall(35)
        description:SetText(config.desc or "")
        description:SetFont("DescriptionFontLarge")
        description:SetContentAlignment(5)
        description:SetTextColor(Color(200, 200, 200))
        description:DockMargin(0, 10, 0, 0)
        local listView = panel:Add("DListView")
        listView:Dock(FILL)
        listView:SetMultiSelect(false)
        listView:AddColumn("Items")
        for _, item in ipairs(lia.option.get(key, config.value) or {}) do
            listView:AddLine(tostring(item))
        end

        local addButton = panel:Add("DButton")
        addButton:Dock(BOTTOM)
        addButton:SetTall(30)
        addButton:SetText("Add Item")
        addButton.DoClick = function()
            Derma_StringRequest("Add Item", "Enter new item:", "", function(text)
                if text and text ~= "" then
                    local current = lia.option.get(key, config.value) or {}
                    table.insert(current, text)
                    lia.option.set(key, current)
                    listView:AddLine(text)
                end
            end)
        end

        local removeButton = panel:Add("DButton")
        removeButton:Dock(BOTTOM)
        removeButton:SetTall(30)
        removeButton:SetText("Remove Selected")
        removeButton.DoClick = function()
            local selected = listView:GetSelected()
            if #selected > 0 then
                local line = selected[1]
                local index = listView:Line(line):GetID()
                local current = lia.option.get(key, config.value) or {}
                table.remove(current, index)
                lia.option.set(key, current)
                listView:RemoveLine(index)
            end
        end
        return container
    end
}

function MODULE:CreateMenuButtons(tabs)
    tabs["Configuration"] = function(panel)
        panel.sidebar = panel:Add("DScrollPanel")
        panel.sidebar:Dock(LEFT)
        panel.sidebar:SetWide(250)
        panel.sidebar:DockMargin(20, 20, 10, 20)
        panel.scroll = panel:Add("DScrollPanel")
        panel.scroll:Dock(FILL)
        panel.scroll:DockMargin(10, 10, 10, 10)
        panel.scroll.Paint = function() end
        panel.categories = {}
        panel.activeTab = nil
        local function addCategory(text)
            if panel.categories[text] then return panel.categories[text].label end
            local categoryLabel = panel.sidebar:Add("DButton")
            categoryLabel:SetText(text)
            categoryLabel:SetTall(40)
            categoryLabel:Dock(TOP)
            categoryLabel:DockMargin(0, 10, 0, 10)
            categoryLabel:SetFont("liaMediumFont")
            categoryLabel:SetTextColor(color_white)
            categoryLabel.Paint = function(btn, w, h)
                if btn:IsHovered() then
                    local underlineWidth = w * 0.4
                    local underlineX = (w - underlineWidth) * 0.5
                    local underlineY = h - 4
                    surface.SetDrawColor(255, 255, 255, 80)
                    surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
                end

                if panel.activeTab == btn then
                    surface.SetDrawColor(color_white)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end
            end

            categoryLabel.DoClick = function(button)
                for _, cat in pairs(panel.categories) do
                    for _, btn in ipairs(cat.buttons) do
                        btn:SetVisible(false)
                    end
                end

                for _, btn in ipairs(panel.categories[text].buttons) do
                    btn:SetVisible(true)
                end

                panel.activeTab = button
            end

            panel.categories[text] = {
                label = categoryLabel,
                buttons = {}
            }
            return categoryLabel
        end

        local function addElement(elementType, key, name, config, category)
            category = category or "Miscellaneous"
            local cat = panel.categories[category]
            if not cat then
                cat = {
                    label = addCategory(category),
                    buttons = {}
                }

                panel.categories[category] = cat
            end

            local panelElement = ConfigFormatting[elementType](key, name, config, panel.scroll)
            panelElement:SetParent(panel.scroll)
            panelElement:Dock(TOP)
            panelElement:DockMargin(20, 10, 20, 10)
            panelElement:SetVisible(false)
            panelElement.Paint = function(_, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                surface.SetDrawColor(255, 255, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            table.insert(cat.buttons, panelElement)
        end

        for key, option in pairs(lia.config.stored) do
            local elementType = option.data and option.data.type or "Generic"
            addElement(elementType, key, option.name, option, option.category)
        end

        local firstCategory = next(panel.categories)
        if firstCategory then
            for _, btn in ipairs(panel.categories[firstCategory].buttons) do
                btn:SetVisible(true)
            end

            panel.activeTab = panel.categories[firstCategory].label
        end

        panel.scroll:InvalidateLayout(true)
    end

    tabs["Settings"] = function(panel)
        panel.sidebar = panel:Add("DScrollPanel")
        panel.sidebar:Dock(LEFT)
        panel.sidebar:SetWide(250)
        panel.sidebar:DockMargin(20, 20, 10, 20)
        panel.scroll = panel:Add("DScrollPanel")
        panel.scroll:Dock(FILL)
        panel.scroll:DockMargin(10, 10, 10, 10)
        panel.scroll.Paint = function() end
        panel.categories = {}
        panel.activeTab = nil
        local function addCategory(text)
            if panel.categories[text] then return panel.categories[text].label end
            local categoryLabel = panel.sidebar:Add("DButton")
            categoryLabel:SetText(text)
            categoryLabel:SetTall(40)
            categoryLabel:Dock(TOP)
            categoryLabel:DockMargin(0, 10, 0, 10)
            categoryLabel:SetFont("liaMediumFont")
            categoryLabel:SetTextColor(color_white)
            categoryLabel.Paint = function(btn, w, h)
                if btn:IsHovered() then
                    local underlineWidth = w * 0.4
                    local underlineX = (w - underlineWidth) * 0.5
                    local underlineY = h - 4
                    surface.SetDrawColor(255, 255, 255, 80)
                    surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
                end

                if panel.activeTab == btn then
                    surface.SetDrawColor(color_white)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end
            end

            categoryLabel.DoClick = function(button)
                for _, cat in pairs(panel.categories) do
                    for _, btn in ipairs(cat.buttons) do
                        btn:SetVisible(false)
                    end
                end

                for _, btn in ipairs(panel.categories[text].buttons) do
                    btn:SetVisible(true)
                end

                panel.activeTab = button
            end

            panel.categories[text] = {
                label = categoryLabel,
                buttons = {}
            }
            return categoryLabel
        end

        local function addElement(elementType, key, name, option, category)
            category = category or "Miscellaneous"
            local cat = panel.categories[category]
            if not cat then
                cat = {
                    label = addCategory(category),
                    buttons = {}
                }

                panel.categories[category] = cat
            end

            local panelElement = OptionFormatting[elementType](key, name, option, panel.scroll)
            panelElement:SetParent(panel.scroll)
            panelElement:Dock(TOP)
            panelElement:DockMargin(20, 10, 20, 10)
            panelElement:SetVisible(false)
            panelElement.Paint = function(_, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                surface.SetDrawColor(255, 255, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            table.insert(cat.buttons, panelElement)
        end

        for key, option in pairs(lia.option.stored) do
            local elementType = option.type
            addElement(elementType, key, option.name, option, option.data and option.data.category)
        end

        local firstCategory = next(panel.categories)
        if firstCategory then
            for _, btn in ipairs(panel.categories[firstCategory].buttons) do
                btn:SetVisible(true)
            end
        end

        panel.scroll:InvalidateLayout(true)
    end
end
