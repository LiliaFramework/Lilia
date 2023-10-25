--------------------------------------------------------------------------------------------------------------------------
chat.liaAddText = chat.liaAddText or chat.AddText
--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
LIA_CVAR_CHATFILTER = CreateClientConVar("lia_chatfilter", "", true, false)
--------------------------------------------------------------------------------------------------------------------------
function MODULE:createChat()
    if IsValid(self.panel) then return end
    self.panel = vgui.Create("liaChatBox")
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:InitPostEntity()
    self:createChat()
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("messagemode") and pressed then
        if not self.panel.active then
            self.panel:setActive(true)
        end

        return true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDShouldDraw(element)
    if element == "CHudChat" then return false end
end

--------------------------------------------------------------------------------------------------------------------------
function chat.AddText(...)
    local show = true
    if IsValid(MODULE.panel) then
        show = MODULE.panel:addText(...)
    end

    if show then
        chat.liaAddText(...)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ChatText(index, name, text, messageType)
    if messageType == "none" and IsValid(self.panel) then
        self.panel:addText(text)
        if lia.config.CustomChatSound and lia.config.CustomChatSound ~= "" then
            surface.PlaySound(lia.config.CustomChatSound)
        else
            chat.PlaySound()
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
concommand.Add(
    "fixchatplz",
    function()
        if IsValid(MODULE.panel) then
            MODULE.panel:Remove()
            MODULE:createChat()
        end
    end
)
--------------------------------------------------------------------------------------------------------------------------