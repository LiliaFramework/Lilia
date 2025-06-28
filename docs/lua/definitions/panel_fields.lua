--[[
    This file documents custom Panel classes defined within the Lilia framework.

    Generated automatically.
]]
--[[
        liaMarkupPanel (DPanel)

        Description:
            Panel that renders text using Garry's Mod markup language.
        Example Usage:
            local pnl = vgui.Create("liaMarkupPanel")
]]
--[[
        liaCharInfo (EditablePanel)

        Description:
            Shows character statistics and fields inside the F1 menu.
        Example Usage:
            local pnl = vgui.Create("liaCharInfo")
]]
--[[
        liaMenu (EditablePanel)

        Description:
            Main F1 menu housing multiple tabs such as Character and Help.
        Example Usage:
            local pnl = vgui.Create("liaMenu")
]]
--[[
        liaClasses (EditablePanel)

        Description:
            Displays available classes and lets the player join one.
        Example Usage:
            local pnl = vgui.Create("liaClasses")
]]
--[[
        liaModelPanel (DModelPanel)

        Description:
            Model panel with custom lighting and mouse controls.
        Example Usage:
            local pnl = vgui.Create("liaModelPanel")
]]
--[[
        FacingModelPanel (DModelPanel)

        Description:
            Simplified model panel that always looks at the model's head.
        Example Usage:
            local pnl = vgui.Create("FacingModelPanel")
]]
--[[
        DProgressBar (DPanel)

        Description:
            Progress bar used for timed actions and displays.
        Example Usage:
            local pnl = vgui.Create("DProgressBar")
]]
--[[
        liaNotice (DLabel)

        Description:
            Small notification label drawn with a blur background.
        Example Usage:
            local pnl = vgui.Create("liaNotice")
]]
--[[
        noticePanel (DPanel)

        Description:
            Larger notification panel with customizable text.
        Example Usage:
            local pnl = vgui.Create("noticePanel")
]]
--[[
        liaChatBox (DPanel)

        Description:
            Custom chat box supporting tabs and command suggestions.
        Example Usage:
            local pnl = vgui.Create("liaChatBox")
]]
--[[
        liaSpawnIcon (DModelPanel)

        Description:
            Spawn icon that properly positions and lights models.
        Example Usage:
            local pnl = vgui.Create("liaSpawnIcon")
]]
--[[
        VoicePanel (DPanel)

        Description:
            HUD element showing players currently speaking.
        Example Usage:
            local pnl = vgui.Create("VoicePanel")
]]
--[[
        liaHorizontalScroll (DPanel)

        Description:
            Scroll panel that lays out children horizontally.
        Example Usage:
            local pnl = vgui.Create("liaHorizontalScroll")
]]
--[[
        liaHorizontalScrollBar (DVScrollBar)

        Description:
            Companion scrollbar used by liaHorizontalScroll.
        Example Usage:
            local bar = vgui.Create("liaHorizontalScrollBar")
]]
--[[
        liaItemMenu (EditablePanel)

        Description:
            Context menu used when interacting with world items.
        Example Usage:
            local pnl = vgui.Create("liaItemMenu")
]]
--[[
        liaAttribBar (DPanel)

        Description:
            Bar widget for allocating starting attribute points.
        Example Usage:
            local pnl = vgui.Create("liaAttribBar")
]]
--[[
        liaCharacterAttribs (liaCharacterCreateStep)

        Description:
            Character creation step for selecting attribute distribution.
        Example Usage:
            local pnl = vgui.Create("liaCharacterAttribs")
]]
--[[
        liaCharacterAttribsRow (DPanel)

        Description:
            Row element within liaCharacterAttribs representing one attribute.
        Example Usage:
            local pnl = vgui.Create("liaCharacterAttribsRow")
]]
--[[
        liaItemIcon (SpawnIcon)

        Description:
            Spawn icon specialized for displaying Lilia items.
        Example Usage:
            local pnl = vgui.Create("liaItemIcon")
]]
--[[
        BlurredDFrame (DFrame)

        Description:
            Frame with a blurred background used for menus.
        Example Usage:
            local pnl = vgui.Create("BlurredDFrame")
]]
--[[
        SemiTransparentDFrame (DFrame)

        Description:
            Frame drawn with a translucent backdrop for overlays.
        Example Usage:
            local pnl = vgui.Create("SemiTransparentDFrame")
]]
--[[
        SemiTransparentDPanel (DPanel)

        Description:
            Panel drawn with a translucent backdrop.
        Example Usage:
            local pnl = vgui.Create("SemiTransparentDPanel")
]]
--[[
        liaDoorMenu (DFrame)

        Description:
            Door permission menu allowing owners to set access levels.
        Example Usage:
            local pnl = vgui.Create("liaDoorMenu")
]]
--[[
        liaScoreboard (EditablePanel)

        Description:
            Custom scoreboard listing players with team sections.
        Example Usage:
            local pnl = vgui.Create("liaScoreboard")
]]
--[[
        liaCharacter (EditablePanel)

        Description:
            Main menu for choosing or loading characters.
        Example Usage:
            local pnl = vgui.Create("liaCharacter")
]]
--[[
        liaCharBGMusic (DPanel)

        Description:
            Handles menu background music playback and fade out.
        Example Usage:
            local pnl = vgui.Create("liaCharBGMusic")
]]
--[[
        liaCharacterCreation (EditablePanel)

        Description:
            Multi-step panel guiding new character creation.
        Example Usage:
            local pnl = vgui.Create("liaCharacterCreation")
]]
--[[
        liaCharacterCreateStep (DScrollPanel)

        Description:
            Base panel for individual character creation steps.
        Example Usage:
            local pnl = vgui.Create("liaCharacterCreateStep")
]]
--[[
        liaCharacterConfirm (SemiTransparentDFrame)

        Description:
            Simple confirmation dialog used in character menu.
        Example Usage:
            local pnl = vgui.Create("liaCharacterConfirm")
]]
--[[
        liaCharacterBiography (liaCharacterCreateStep)

        Description:
            Character creation step for entering name and description.
        Example Usage:
            local pnl = vgui.Create("liaCharacterBiography")
]]
--[[
        liaCharacterFaction (liaCharacterCreateStep)

        Description:
            Character creation step for selecting a faction.
        Example Usage:
            local pnl = vgui.Create("liaCharacterFaction")
]]
--[[
        liaCharacterModel (liaCharacterCreateStep)

        Description:
            Character creation step for choosing a player model.
        Example Usage:
            local pnl = vgui.Create("liaCharacterModel")
]]
--[[
        liaInventory (DFrame)

        Description:
            Base inventory window that listens for inventory updates.
        Example Usage:
            local pnl = vgui.Create("liaInventory")
]]
--[[
        liaGridInventory (liaInventory)

        Description:
            Inventory window using a grid layout of item slots.
        Example Usage:
            local pnl = vgui.Create("liaGridInventory")
]]
--[[
        liaGridInvItem (liaItemIcon)

        Description:
            Item icon used within grid inventories.
        Example Usage:
            local pnl = vgui.Create("liaGridInvItem")
]]
--[[
        liaGridInventoryPanel (DPanel)

        Description:
            Panel that arranges item icons in a grid and manages drag/drop.
        Example Usage:
            local pnl = vgui.Create("liaGridInventoryPanel")
]]
--[[
        Vendor (EditablePanel)

        Description:
            Panel displaying vendor goods and buy/sell options.
        Example Usage:
            local pnl = vgui.Create("Vendor")
]]
--[[
        VendorItem (DPanel)

        Description:
            Entry within the vendor menu representing a single item.
        Example Usage:
            local pnl = vgui.Create("VendorItem")
]]
--[[
        VendorEditor (DFrame)

        Description:
            Window used by admins to configure vendor NPCs.
        Example Usage:
            local pnl = vgui.Create("VendorEditor")
]]
--[[
        VendorFactionEditor (DFrame)

        Description:
            Allows choosing which factions and classes a vendor serves.
        Example Usage:
            local pnl = vgui.Create("VendorFactionEditor")
]]
