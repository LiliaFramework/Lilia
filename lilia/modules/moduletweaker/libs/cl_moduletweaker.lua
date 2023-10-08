--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:SetTitle(L"Modules")
    self:SetSize(256, 512)
    self:MakePopup()
    self:Center()
    self.modules = {}
    local loading = self:Add("DLabel")
    loading:Dock(FILL)
    loading:SetText(L"loading")
    loading:SetContentAlignment(5)
    lia.gui.moduleConfig = self
    local info = self:Add("DLabel")
    info:SetText("The map must be restarted after making changes!")
    info:Dock(TOP)
    info:DockMargin(0, 0, 0, 4)
    info:SetContentAlignment(5)
    local scroll = self:Add("DScrollPanel")
    scroll:Dock(FILL)
    local function onChange(box, value)
        local module = box.module
        if not module then return end
        net.Start("liaModuleDisable")
        net.WriteString(module)
        net.WriteBit(value)
        net.SendToServer()
    end

    hook.Add(
        "RetrievedModuleList",
        self,
        function(_, modules)
            for name, disabled in SortedPairs(modules) do
                local box = scroll:Add("DCheckBoxLabel")
                box:Dock(TOP)
                box:DockMargin(0, 0, 0, 4)
                box:SetValue(disabled)
                box:SetText(name)
                box.module = name
                box.OnChange = onChange
                self.modules[name] = box
            end

            loading:Remove()
        end
    )

    hook.Add(
        "ModuleConfigDisabled",
        self,
        function(_, module, disabled)
            local box = self.modules[module]
            if IsValid(box) then
                box:SetValue(disabled)
            end
        end
    )

    net.Start("liaModuleList")
    net.SendToServer()
end

--------------------------------------------------------------------------------------------------------
vgui.Register("liaModuleList", PANEL, "DFrame")
--------------------------------------------------------------------------------------------------------