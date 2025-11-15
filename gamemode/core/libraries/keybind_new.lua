        function buildKeybinds(parent)
            parent:Clear()
            local allowEdit = lia.config.get("AllowKeybindEditing", true)

            -- Create scroll panel for all keybinds
            local scrollPanel = parent:Add("liaScrollPanel")
            scrollPanel:Dock(FILL)
            scrollPanel:InvalidateLayout(true)
            if not IsValid(scrollPanel.VBar) then scrollPanel:PerformLayout() end
            local canvas = scrollPanel:GetCanvas()
            canvas:DockPadding(10, 10, 10, 10)

            local taken = {}
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) and data.value then taken[data.value] = action end
            end

            -- Get all keybinds and sort them alphabetically
            local actions = {}
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) then
                    table.insert(actions, action)
                end
            end

            table.sort(actions, function(a, b)
                local la, lb = #tostring(a), #tostring(b)
                if la == lb then return tostring(a) < tostring(b) end
                return la < lb
            end)

            -- Add keybinds to the scroll panel
            for _, action in ipairs(actions) do
                local data = lia.keybind.stored[action]
                local keybindPanel = KeybindFormatting.Keybind(action, data, canvas, allowEdit, taken, buildKeybinds)
                keybindPanel:Dock(TOP)
                keybindPanel:DockMargin(10, 10, 10, 0)
                keybindPanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(50, 50, 60, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
            end

            -- Add reset button at the bottom if editing is allowed
            if allowEdit then
                local resetAllBtn = vgui.Create("liaMediumButton", canvas)
                resetAllBtn:Dock(TOP)
                resetAllBtn:DockMargin(10, 20, 10, 0)
                resetAllBtn:SetTall(60)
                resetAllBtn:SetText(L("resetAllKeybinds"))
                resetAllBtn.DoClick = function()
                    for action, data in pairs(lia.keybind.stored) do
                        if istable(data) and data.default then
                            if data.value and lia.keybind.stored[data.value] == action then lia.keybind.stored[data.value] = nil end
                            data.value = data.default
                            lia.keybind.stored[data.default] = action
                        end
                    end

                    lia.keybind.save()
                    buildKeybinds(parent)
                end
            end
        end
