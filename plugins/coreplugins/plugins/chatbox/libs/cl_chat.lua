LIA_CVAR_CHATFILTER = CreateClientConVar("lia_chatfilter", "", true, false)

function PLUGIN:createChat()
    if IsValid(self.panel) then return end
    self.panel = vgui.Create("liaChatBox")
end

function PLUGIN:InitPostEntity()
    self:createChat()
end

function PLUGIN:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()

    if bind:find("messagemode") and pressed then
        if not self.panel.active then
            self.panel:setActive(true)
        end

        return true
    end
end

function PLUGIN:HUDShouldDraw(element)
    if element == "CHudChat" then return false end
end

chat.liaAddText = chat.liaAddText or chat.AddText
local PLUGIN = PLUGIN

function chat.AddText(...)
    local show = true

    if IsValid(PLUGIN.panel) then
        show = PLUGIN.panel:addText(...)
    end

    if show then
        chat.liaAddText(...)
    end
end

function PLUGIN:ChatText(index, name, text, messageType)
    if messageType == "none" and IsValid(self.panel) then
        self.panel:addText(text)

        if SOUND_CUSTOM_CHAT_SOUND and SOUND_CUSTOM_CHAT_SOUND ~= "" then
            surface.PlaySound(SOUND_CUSTOM_CHAT_SOUND)
        else
            chat.PlaySound()
        end
    end
end

concommand.Add("fixchatplz", function()
    if IsValid(PLUGIN.panel) then
        PLUGIN.panel:Remove()
        PLUGIN:createChat()
    end
end)