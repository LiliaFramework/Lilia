# Notification Panels Library

A collection of panels for displaying notifications, alerts, and status messages within the Lilia framework.

---

## Overview

The notification panel library provides components for displaying various types of notifications and alerts to users. These panels handle different notification types with appropriate styling, icons, and behaviors, from simple text notifications to complex interactive alerts with buttons and progress indicators.

---

### liaNotice

**Purpose**

Small label for quick notifications. It draws a blurred backdrop and fades away after a short delay. Supports different notification types with icons and colors.

**When Called**

This panel is called when:
- Displaying temporary status messages
- Showing system notifications
- Providing user feedback for actions
- Creating non-intrusive alert messages

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetText(text)` – sets the notification message text.
- `SetType(type)` – sets the notification type (info, error, success, warning, money, admin, default) to change icon and color.

**Example Usage**

```lua
-- Create a notification
local notice = vgui.Create("liaNotice")
notice:SetText("This is a notification!")
notice:SetType("info") -- Sets icon and color

-- Or create with specific positioning
notice:SetPos(10, 10)
notice:SetSize(300, 54)

-- Custom notification types
notice:SetType("success") -- Green checkmark
notice:SetType("error")   -- Red X
notice:SetType("warning") -- Orange warning triangle
```

---

### noticePanel

**Purpose**

Expanded version of `liaNotice` supporting more text and optional buttons. Often used for yes/no prompts.

**When Called**

This panel is called when:
- Displaying confirmation dialogs
- Showing detailed notifications with actions
- Creating interactive alert messages
- Providing user choice prompts

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `CalcWidth(padding)` – recalculates the panel width based on the inner label and supplied padding.

**Example Usage**

```lua
-- Create a notice panel
local notice = vgui.Create("noticePanel")
notice:SetText("Are you sure you want to delete this item?")
notice:SetSize(300, 100)
notice:Center()

-- Add buttons to the notice
notice:AddButton("Yes", function()
    print("User confirmed deletion")
    notice:Remove()
end)

notice:AddButton("No", function()
    print("User cancelled")
    notice:Remove()
end)
```

---
