lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
--[[
    lia.option.add(key, name, desc, default, callback, data)

       Description:
          Adds a configuration option to the lia.option system.

       Parameters:
          key (string) — The unique key for the option.
          name (string) — The display name of the option.
          desc (string) — A brief description of the option's purpose.
          default (any) — The default value for this option.
          callback (function) — A function to call when the option’s value changes (optional).
          data (table) — Additional data describing the option (e.g., min, max, type, category, visible, shouldNetwork).

    Returns:
        nil

    Realm:
        Shared
]]
function lia.option.add(key, name, desc, default, callback, data)
    assert(isstring(key), "Expected option key to be a string, got " .. type(key))
    assert(isstring(name), "Expected option name to be a string, got " .. type(name))
    assert(istable(data), "Expected option data to be a table, got " .. type(data))
    local t = type(default)
    local optionType = t == "boolean" and "Boolean" or t == "number" and (math.floor(default) == default and "Int" or "Float") or t == "table" and default.r and default.g and default.b and "Color" or "Generic"
    if optionType == "Int" or optionType == "Float" then
        data.min = data.min or optionType == "Int" and math.floor(default / 2) or default / 2
        data.max = data.max or optionType == "Int" and math.floor(default * 2) or default * 2
    end

    if data.type then optionType = data.type end
    local old = lia.option.stored[key]
    local value = old and old.value or default
    lia.option.stored[key] = {
        name = name,
        desc = desc,
        data = data,
        value = value,
        default = default,
        callback = callback,
        type = optionType,
        visible = data.visible,
        shouldNetwork = data.shouldNetwork
    }
end

--[[
    lia.option.set(key, value)

       Description:
          Sets the value of a specified option, saves locally, and optionally networks to the server.

       Parameters:
          key (string) — The unique key identifying the option.
          value (any) — The new value to assign to this option.

    Returns:
        nil

    Realm:
        Client
]]
function lia.option.set(key, value)
    local opt = lia.option.stored[key]
    if not opt then return end
    local old = opt.value
    opt.value = value
    if opt.callback then opt.callback(old, value) end
    lia.option.save()
    if opt.shouldNetwork and SERVER then hook.Run("liaOptionReceived", ply, key, value) end
end

--[[
    lia.option.get(key, default)

       Description:
          Retrieves the value of a specified option, or returns a default if it doesn't exist.

       Parameters:
          key (string) — The unique key identifying the option.
          default (any) — The value to return if the option is not found.

    Returns:
        (any) The current value of the option or the provided default.

    Realm:
        Client
]]
function lia.option.get(key, default)
    local opt = lia.option.stored[key]
    if opt then
        if opt.value ~= nil then return opt.value end
        if opt.default ~= nil then return opt.default end
    end
    return default
end

--[[
    lia.option.save()

       Description:
          Saves all current option values to a file, named based on the server IP, within the active gamemode folder.

       Parameters:
          None

    Returns:
        nil

    Realm:
        Client
]]
function lia.option.save()
    local dir = "lilia/options/" .. engine.ActiveGamemode()
    file.CreateDir(dir)
    local ip = string.Explode(":", game.GetIPAddress())[1]
    local name = ip:gsub("%.", "_")
    local path = dir .. "/" .. name .. ".txt"
    local out = {}
    for k, v in pairs(lia.option.stored) do
        if v.value ~= nil then out[k] = v.value end
    end

    local json = util.TableToJSON(out, true)
    if json then file.Write(path, json) end
end

--[[
    lia.option.load()

       Description:
          Loads saved option values from disk based on server IP and applies them to lia.option.stored.

       Parameters:
          None

    Returns:
        nil

    Realm:
        Client
]]
function lia.option.load()
    local dir = "lilia/options/" .. engine.ActiveGamemode()
    file.CreateDir(dir)
    local ip = string.Explode(":", game.GetIPAddress())[1]
    local name = ip:gsub("%.", "_")
    local path = dir .. "/" .. name .. ".txt"
    local data = file.Read(path, "DATA")
    if data then
        local saved = util.JSONToTable(data)
        for k, v in pairs(saved) do
            if lia.option.stored[k] then lia.option.stored[k].value = v end
        end
    end

    hook.Run("InitializedOptions")
end

hook.Add("PopulateConfigurationButtons", "liaOptionsPopulate", function(pages)
    local OptionFormatting = {
        Int = function(key, name, cfg, parent)
            local c = vgui.Create("DPanel", parent)
            c:SetTall(220)
            c:Dock(TOP)
            c:DockMargin(0, 60, 0, 10)
            c.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local p = c:Add("DPanel")
            p:Dock(FILL)
            p.Paint = nil
            local lbl = p:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(45)
            lbl:SetText(name)
            lbl:SetFont("ConfigFontLarge")
            lbl:SetContentAlignment(5)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:DockMargin(0, 20, 0, 0)
            local desc = p:Add("DLabel")
            desc:Dock(TOP)
            desc:SetTall(35)
            desc:SetText(cfg.desc or "")
            desc:SetFont("DescriptionFontLarge")
            desc:SetContentAlignment(5)
            desc:SetTextColor(Color(200, 200, 200))
            desc:DockMargin(0, 10, 0, 0)
            local slider = p:Add("DNumSlider")
            slider:Dock(FILL)
            slider:DockMargin(10, 0, 10, 0)
            slider:SetMin(lia.config.get(key .. "_min", cfg.data and cfg.data.min or 0))
            slider:SetMax(lia.config.get(key .. "_max", cfg.data and cfg.data.max or 1))
            slider:SetDecimals(0)
            slider:SetValue(lia.option.get(key, cfg.value))
            slider.PerformLayout = function()
                slider.Label:SetWide(100)
                slider.TextArea:SetWide(50)
            end

            slider.OnValueChanged = function(_, v) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.floor(v)) end) end
            return c
        end,
        Float = function(key, name, cfg, parent)
            local c = vgui.Create("DPanel", parent)
            c:SetTall(220)
            c:Dock(TOP)
            c:DockMargin(0, 60, 0, 10)
            c.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local p = c:Add("DPanel")
            p:Dock(FILL)
            p.Paint = nil
            local lbl = p:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(45)
            lbl:SetText(name)
            lbl:SetFont("ConfigFontLarge")
            lbl:SetContentAlignment(5)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:DockMargin(0, 20, 0, 0)
            local desc = p:Add("DLabel")
            desc:Dock(TOP)
            desc:SetTall(35)
            desc:SetText(cfg.desc or "")
            desc:SetFont("DescriptionFontLarge")
            desc:SetContentAlignment(5)
            desc:SetTextColor(Color(200, 200, 200))
            desc:DockMargin(0, 10, 0, 0)
            local slider = p:Add("DNumSlider")
            slider:Dock(FILL)
            slider:DockMargin(10, 0, 10, 0)
            slider:SetMin(lia.config.get(key .. "_min", cfg.data and cfg.data.min or 0))
            slider:SetMax(lia.config.get(key .. "_max", cfg.data and cfg.data.max or 1))
            slider:SetDecimals(2)
            slider:SetValue(lia.option.get(key, cfg.value))
            slider.PerformLayout = function()
                slider.Label:SetWide(100)
                slider.TextArea:SetWide(50)
            end

            slider.OnValueChanged = function(_, v) timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, math.Round(v, 2)) end) end
            return c
        end,
        Generic = function(key, name, cfg, parent)
            local c = vgui.Create("DPanel", parent)
            c:SetTall(220)
            c:Dock(TOP)
            c:DockMargin(0, 60, 0, 10)
            c.Paint = function() end
            local p = c:Add("DPanel")
            p:Dock(FILL)
            p.Paint = nil
            local lbl = p:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(45)
            lbl:SetText(name)
            lbl:SetFont("ConfigFontLarge")
            lbl:SetContentAlignment(5)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:DockMargin(0, 20, 0, 0)
            local desc = p:Add("DLabel")
            desc:Dock(TOP)
            desc:SetTall(35)
            desc:SetText(cfg.desc or "")
            desc:SetFont("DescriptionFontLarge")
            desc:SetContentAlignment(5)
            desc:SetTextColor(Color(200, 200, 200))
            desc:DockMargin(0, 10, 0, 0)
            local entry = p:Add("DTextEntry")
            entry:Dock(TOP)
            entry:SetTall(60)
            entry:DockMargin(300, 10, 300, 0)
            entry:SetText(tostring(lia.option.get(key, cfg.value)))
            entry:SetFont("ConfigFontLarge")
            entry:SetTextColor(Color(255, 255, 255))
            entry.OnEnter = function(btn) lia.option.set(key, btn:GetText()) end
            return c
        end,
        Boolean = function(key, name, cfg, parent)
            local c = vgui.Create("DPanel", parent)
            c:SetTall(220)
            c:Dock(TOP)
            c:DockMargin(0, 60, 0, 10)
            c.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local p = c:Add("DPanel")
            p:Dock(FILL)
            p.Paint = nil
            local lbl = p:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(45)
            lbl:SetText(name)
            lbl:SetFont("ConfigFontLarge")
            lbl:SetContentAlignment(5)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:DockMargin(0, 20, 0, 0)
            local desc = p:Add("DLabel")
            desc:Dock(TOP)
            desc:SetTall(35)
            desc:SetText(cfg.desc or "")
            desc:SetFont("DescriptionFontLarge")
            desc:SetContentAlignment(5)
            desc:SetTextColor(Color(200, 200, 200))
            desc:DockMargin(0, 10, 0, 0)
            local btn = p:Add("DButton")
            btn:Dock(TOP)
            btn:SetTall(100)
            btn:DockMargin(100, 10, 100, 0)
            btn:SetText("")
            btn.Paint = function(_, w, h)
                local ic = lia.option.get(key, cfg.value) and getIcon("0xe880", true) or getIcon("0xf096", true)
                lia.util.drawText(ic, w / 2, h / 2 - 10, color_white, 1, 1, "liaIconsHugeNew")
            end

            btn.DoClick = function() lia.option.set(key, not lia.option.get(key, cfg.value)) end
            return c
        end,
        Color = function(key, name, cfg, parent)
            local c = vgui.Create("DPanel", parent)
            c:SetTall(220)
            c:Dock(TOP)
            c:DockMargin(0, 60, 0, 10)
            c.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local p = c:Add("DPanel")
            p:Dock(FILL)
            p.Paint = nil
            local lbl = p:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(45)
            lbl:SetText(name)
            lbl:SetFont("ConfigFontLarge")
            lbl:SetContentAlignment(5)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:DockMargin(0, 20, 0, 0)
            local desc = p:Add("DLabel")
            desc:Dock(TOP)
            desc:SetTall(35)
            desc:SetText(cfg.desc or "")
            desc:SetFont("DescriptionFontLarge")
            desc:SetContentAlignment(5)
            desc:SetTextColor(Color(200, 200, 200))
            desc:DockMargin(0, 10, 0, 0)
            local btn = p:Add("DButton")
            btn:Dock(FILL)
            btn:DockMargin(10, 0, 10, 0)
            btn:SetText("")
            btn:SetCursor("hand")
            btn.Paint = function(_, w, h)
                local col = lia.option.get(key, cfg.value)
                surface.SetDrawColor(col)
                surface.DrawRect(10, h / 2 - 15, w - 20, 30)
                draw.RoundedBox(2, 10, h / 2 - 15, w - 20, 30, Color(255, 255, 255, 50))
            end

            btn.DoClick = function()
                if IsValid(btn.picker) then btn.picker:Remove() end
                local frm = vgui.Create("DFrame")
                frm:SetSize(300, 400)
                frm:Center()
                frm:MakePopup()
                local mixer = frm:Add("DColorMixer")
                mixer:Dock(FILL)
                mixer:SetPalette(true)
                mixer:SetAlphaBar(true)
                mixer:SetWangs(true)
                mixer:SetColor(lia.option.get(key, cfg.value))
                local apply = frm:Add("DButton")
                apply:Dock(BOTTOM)
                apply:SetTall(40)
                apply:SetText("Apply")
                apply:SetTextColor(color_white)
                apply:SetFont("ConfigFontLarge")
                apply:DockMargin(10, 10, 10, 10)
                apply.Paint = function(self, w, h)
                    surface.SetDrawColor(Color(0, 150, 0))
                    surface.DrawRect(0, 0, w, h)
                    if self:IsHovered() then
                        surface.SetDrawColor(Color(0, 180, 0))
                        surface.DrawRect(0, 0, w, h)
                    end

                    surface.SetDrawColor(Color(255, 255, 255))
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                apply.DoClick = function()
                    timer.Create("ConfigChange" .. name, 1, 1, function() lia.option.set(key, frm.curColor) end)
                    frm:Remove()
                end

                mixer.ValueChanged = function(_, v) frm.curColor = v end
                btn.picker = frm
            end
            return c
        end,
        Table = function(key, name, cfg, parent)
            local c = vgui.Create("DPanel", parent)
            c:SetTall(220)
            c:Dock(TOP)
            c:DockMargin(0, 60, 0, 10)
            c.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200)) end
            local p = c:Add("DPanel")
            p:Dock(FILL)
            p.Paint = nil
            local lbl = p:Add("DLabel")
            lbl:Dock(TOP)
            lbl:SetTall(45)
            lbl:SetText(name)
            lbl:SetFont("ConfigFontLarge")
            lbl:SetContentAlignment(5)
            lbl:SetTextColor(Color(255, 255, 255))
            lbl:DockMargin(0, 20, 0, 0)
            local desc = p:Add("DLabel")
            desc:Dock(TOP)
            desc:SetTall(35)
            desc:SetText(cfg.desc or "")
            desc:SetFont("DescriptionFontLarge")
            desc:SetContentAlignment(5)
            desc:SetTextColor(Color(200, 200, 200))
            desc:DockMargin(0, 10, 0, 0)
            local combo = p:Add("DComboBox")
            combo:Dock(TOP)
            combo:SetTall(60)
            combo:DockMargin(300, 10, 300, 0)
            combo:SetFont("ConfigFontLarge")
            combo:SetTextColor(Color(255, 255, 255))
            local opts = cfg.data and cfg.data.options or {}
            local cur = lia.option.get(key, cfg.value)
            combo:SetValue(tostring(cur))
            combo.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
                self:DrawTextEntryText(Color(255, 255, 255), Color(255, 255, 255), Color(255, 255, 255))
            end

            for _, opt in ipairs(opts) do
                combo:AddChoice(opt, opt, opt == cur)
            end

            combo.OnSelect = function(_, _, v) lia.option.set(key, v) end
            return c
        end
    }

    local function buildOptions(parent, filter)
        local categories = {}
        local keys = {}
        for k in pairs(lia.option.stored) do
            keys[#keys + 1] = k
        end

        table.sort(keys, function(a, b) return lia.option.stored[a].name < lia.option.stored[b].name end)
        for _, key in ipairs(keys) do
            local opt = lia.option.stored[key]
            if not opt.visible or type(opt.visible) == "function" and opt.visible() then
                local name = opt.name
                local desc = opt.desc or ""
                local ln, ld = name:lower(), desc:lower()
                if filter == "" or ln:find(filter, 1, true) or ld:find(filter, 1, true) then
                    local catName = opt.data and opt.data.category or "Miscellaneous"
                    categories[catName] = categories[catName] or {}
                    categories[catName][#categories[catName] + 1] = {
                        key = key,
                        name = name,
                        config = opt,
                        elemType = opt.type or "Generic"
                    }
                end
            end
        end

        local catNames = {}
        for name in pairs(categories) do
            catNames[#catNames + 1] = name
        end

        table.sort(catNames)
        for _, catName in ipairs(catNames) do
            local items = categories[catName]
            local cat = vgui.Create("DCollapsibleCategory", parent)
            cat:Dock(TOP)
            cat:SetLabel(catName)
            cat:SetExpanded(true)
            cat:DockMargin(0, 0, 0, 10)
            cat.Header:SetContentAlignment(5)
            cat.Header:SetTall(30)
            cat.Header:SetFont("liaMediumFont")
            cat.Header:SetTextColor(Color(255, 255, 255))
            cat.Paint = function() end
            cat.Header.Paint = function(_, w, h)
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawRect(1, 1, w - 2, h - 2)
            end

            cat.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 60)) end
            local body = vgui.Create("DPanel", cat)
            body:SetTall(#items * 240)
            body.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 50)) end
            cat:SetContents(body)
            for _, v in ipairs(items) do
                local panel = OptionFormatting[v.elemType](v.key, v.name, v.config, body)
                panel:Dock(TOP)
                panel:DockMargin(10, 10, 10, 0)
                panel.Paint = function(_, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end
            end
        end
    end

    pages[#pages + 1] = {
        name = L("options"),
        drawFunc = function(parent)
            parent:Clear()
            local searchEntry = vgui.Create("DTextEntry", parent)
            searchEntry:Dock(TOP)
            searchEntry:SetTall(30)
            searchEntry:DockMargin(5, 5, 5, 5)
            searchEntry:SetPlaceholderText(L("searchOptions"))
            local scroll = vgui.Create("DScrollPanel", parent)
            scroll:Dock(FILL)
            local function refresh()
                scroll:Clear()
                buildOptions(scroll, searchEntry:GetValue():lower())
            end

            searchEntry.OnTextChanged = function() refresh() end
            refresh()
        end
    }
end)

lia.option.add("descriptionWidth", "Description Width", "Adjust the description width on the HUD", 0.5, nil, {
    category = "HUD",
    min = 0.1,
    max = 1,
    decimals = 2
})