lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--[[
    lia.attribs.loadFromDir(directory)

    Description:
        Loads attribute definitions from all Lua files in the given directory.
        Files beginning with "sh_" are treated as shared and loaded on both client and server.
        Each file must return an ATTRIBUTE table, which is then stored in lia.attribs.list
        under a key derived from the filename (without the "sh_" prefix or ".lua" extension).

    Parameters:
        directory (string) – Path to the folder containing attribute Lua files.

    Realm:
        Shared

    Returns:
        None
]]
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        if MODULE then ATTRIBUTE.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
        ATTRIBUTE.desc = ATTRIBUTE.desc or "No description available."
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    --[[
        lia.attribs.setup(client)

        Description:
            Initializes attributes for a given client’s character.
            Iterates over all entries in lia.attribs.list, retrieves the character’s
            attribute value, and calls the attribute’s OnSetup callback if it exists.

        Parameters:
            client (Player) – The player whose character attributes should be set up.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.attribs.setup(client)
        local character = client:getChar()
        if not character then return end
        for attribID, attribData in pairs(lia.attribs.list) do
            local value = character:getAttrib(attribID, 0)
            if attribData.OnSetup then attribData:OnSetup(client, value) end
        end
    end
end

hook.Add("CreateMenuButtons", "AttributeMenuButtons", function(tabs)
    tabs["Attributes"] = function(panel)
        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:Dock(FILL)
        local iconLayout = vgui.Create("DIconLayout", scroll)
        iconLayout:Dock(FILL)
        iconLayout:DockMargin(0, 50, 0, 0)
        iconLayout:SetSpaceY(5)
        iconLayout:SetSpaceX(5)
        iconLayout.PerformLayout = function(self)
            local y = 0
            local parentWidth = self:GetWide()
            for _, child in ipairs(self:GetChildren()) do
                child:SetPos((parentWidth - child:GetWide()) / 2, y)
                y = y + child:GetTall() + self:GetSpaceY()
            end

            self:SetTall(y)
        end

        for id, attr in pairs(lia.attribs.list) do
            local item = vgui.Create("DPanel", iconLayout)
            item:SetSize(panel:GetWide(), 100)
            item.Paint = function(_, w, h)
                draw.RoundedBox(4, 0, 0, w, h - 10, Color(40, 40, 40, 200))
                draw.SimpleText(attr.name, "liaMediumFont", 20, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(attr.desc or "", "liaSmallFont", 20, 35, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                local value = LocalPlayer():getChar():getAttrib(id)
                local max = attr.max or 100
                local fraction = value / max
                local progressBar = vgui.Create("DProgressBar", item)
                progressBar:SetPos(20, h - 40)
                progressBar:SetSize(w - 40, 25)
                progressBar:SetFraction(fraction)
                progressBar:SetText(string.format("%d / %d", value, max))
            end
        end

        panel:InvalidateLayout(true)
    end
end)