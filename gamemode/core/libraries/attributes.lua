lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--[[ 
   lia.attribs.loadFromDir(directory)

   Description:
      Loads all Lua attribute files (*.lua) from the specified directory 
      and adds them to lia.attribs.list.

   Parameters:
      directory (string) - The path to the directory containing attribute files.

   Returns:
      nil

   Realm:
      Shared

   Internal Function:
      true

   Example Usage:
      lia.attribs.loadFromDir("path/to/attributes")
]]
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
    --[[ 
   Function: lia.attribs.setup

   Description:
      Initializes all attributes for a player's character.
      If an attribute has an OnSetup function, it will be called.

   Parameters:
      client (Player) - The player whose character's attributes are being set up.

   Returns:
      nil

   Realm:
      Shared

   Internal Function:
      true

   Example Usage:
      lia.attribs.setup(client)
]]
    function lia.attribs.setup(client)
        local character = client:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if v.OnSetup then v:OnSetup(client, character:getAttrib(k, 0)) end
            end
        end
    end
end

hook.Add("CreateMenuButtons", "AttributeMenuButtons", function(tabs)
    local client = LocalPlayer()
    tabs["Attributes"] = function(panel)
        local char = client:getChar()
        if not char then
            print("No character found!")
            return
        end

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