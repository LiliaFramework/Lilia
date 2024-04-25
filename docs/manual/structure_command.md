# Structure - Command

```lua
lia.command.add("charsetskin", {
    -- This command is restricted to administrators only by default. CAMI can change this
    adminOnly = true,

    -- Specifies the required privilege for using this command
    privilege = "Change Skin", -- This would end up being the permission "Commands - Change Skin"

    -- Command syntax with name and an optional skin number
    syntax = "<string name> [number skin]",

    -- Execute this function when the command is used
    onRun = function(client, arguments)
        -- Parse the second argument as a number (skin)
        local skin = tonumber(arguments[2])

        -- Find the player specified by name in the first argument
        local target = lia.command.findPlayer(client, arguments[1])

        -- Check if the target player is valid and has a character
        if IsValid(target) and target:getChar() then
            -- Set the "skin" data attribute of the target's character
            target:getChar():setData("skin", skin)

            -- Change the skin of the target player, defaulting to 0 if skin is not provided
            target:SetSkin(skin or 0)

            -- Notify the client about the skin change
            client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
        end
    }
})

```

## Command Variables

- **privilege**: This variable specifies the permission associated with the command. It determines who is allowed to use the command and what actions they can perform.

- **adminOnly** or **superAdminOnly**: These variables are used to categorize the privilege into different levels. You can choose either one of them, and if set to false, it means that the command can be used by regular users as well.

- **syntax**: This variable provides information about the command's syntax. It helps users understand how to correctly structure their input when using the command.

- **onRun**: This is a function that defines what actions should be executed when the command is used. It specifies the actual behavior of the command, including any processing or tasks it should perform.
